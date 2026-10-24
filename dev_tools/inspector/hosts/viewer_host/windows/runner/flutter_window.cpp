#include "flutter_window.h"

#include <optional>

#include "flutter/generated_plugin_registrant.h"

namespace {
constexpr int kMinimumClientWidth = 1280;
constexpr int kMinimumClientHeight = 1000;

// Convert logical client bounds to physical outer-window bounds at this DPI.
RECT MinimumWindowBounds(HWND hwnd) {
  const UINT dpi = GetDpiForWindow(hwnd);
  RECT bounds = {0, 0, MulDiv(kMinimumClientWidth, dpi, 96),
                 MulDiv(kMinimumClientHeight, dpi, 96)};
  AdjustWindowRectExForDpi(
      &bounds, static_cast<DWORD>(GetWindowLongPtr(hwnd, GWL_STYLE)), FALSE,
      static_cast<DWORD>(GetWindowLongPtr(hwnd, GWL_EXSTYLE)), dpi);
  return bounds;
}

void EnforceInitialMinimum(HWND hwnd) {
  const RECT minimum = MinimumWindowBounds(hwnd);
  RECT outer;
  GetWindowRect(hwnd, &outer);
  const LONG width = outer.right - outer.left;
  const LONG height = outer.bottom - outer.top;
  const LONG minimum_width = minimum.right - minimum.left;
  const LONG minimum_height = minimum.bottom - minimum.top;
  if (width < minimum_width || height < minimum_height) {
    SetWindowPos(hwnd, nullptr, 0, 0,
                 width < minimum_width ? minimum_width : width,
                 height < minimum_height ? minimum_height : height,
                 SWP_NOMOVE | SWP_NOZORDER | SWP_NOACTIVATE);
  }
}
}  // namespace

FlutterWindow::FlutterWindow(const flutter::DartProject& project)
    : project_(project) {}

FlutterWindow::~FlutterWindow() {}

bool FlutterWindow::OnCreate() {
  if (!Win32Window::OnCreate()) {
    return false;
  }

  EnforceInitialMinimum(GetHandle());
  RECT frame = GetClientArea();

  // The size here must match the window dimensions to avoid unnecessary surface
  // creation / destruction in the startup path.
  flutter_controller_ = std::make_unique<flutter::FlutterViewController>(
      frame.right - frame.left, frame.bottom - frame.top, project_);
  // Ensure that basic setup of the controller was successful.
  if (!flutter_controller_->engine() || !flutter_controller_->view()) {
    return false;
  }
  RegisterPlugins(flutter_controller_->engine());
  SetChildContent(flutter_controller_->view()->GetNativeWindow());

  flutter_controller_->engine()->SetNextFrameCallback([&]() {
    this->Show();
  });

  // Flutter can complete the first frame before the "show window" callback is
  // registered. The following call ensures a frame is pending to ensure the
  // window is shown. It is a no-op if the first frame hasn't completed yet.
  flutter_controller_->ForceRedraw();

  return true;
}

void FlutterWindow::OnDestroy() {
  if (flutter_controller_) {
    flutter_controller_ = nullptr;
  }

  Win32Window::OnDestroy();
}

LRESULT
FlutterWindow::MessageHandler(HWND hwnd, UINT const message,
                              WPARAM const wparam,
                              LPARAM const lparam) noexcept {
  // Development chrome minimum in logical client pixels (owner-authorized).
  // Include non-client borders and DPI so the Flutter viewport keeps this size.
  if (message == WM_GETMINMAXINFO) {
    const RECT minimum = MinimumWindowBounds(hwnd);
    auto* limits = reinterpret_cast<MINMAXINFO*>(lparam);
    limits->ptMinTrackSize.x = minimum.right - minimum.left;
    limits->ptMinTrackSize.y = minimum.bottom - minimum.top;
    return 0;
  }

  // Give Flutter, including plugins, an opportunity to handle window messages.
  if (flutter_controller_) {
    std::optional<LRESULT> result =
        flutter_controller_->HandleTopLevelWindowProc(hwnd, message, wparam,
                                                      lparam);
    if (result) {
      return *result;
    }
  }

  switch (message) {
    case WM_FONTCHANGE:
      flutter_controller_->engine()->ReloadSystemFonts();
      break;
  }

  return Win32Window::MessageHandler(hwnd, message, wparam, lparam);
}
