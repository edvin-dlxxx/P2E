const fs=require('node:fs');
const {mergeSelect}=require('./arb_select.cjs');
const {concepts}=JSON.parse(fs.readFileSync('docs/snapshots/2026-10-20_development-icons/icons.json'));
const persian=`add=افزودن|add_large=افزودن بزرگ|add_shopping_cart=افزودن به سبد خرید|arrow_cool_down=پیکان کاهش|arrow_down=پیکان پایین|arrow_down_alt=پیکان پایین جایگزین|arrow_drop_down=مثلث پایین|arrow_drop_left=مثلث چپ|arrow_drop_right=مثلث راست|arrow_drop_up=مثلث بالا|arrow_left=پیکان چپ|arrow_left_alt=پیکان چپ جایگزین|arrow_right=پیکان راست|arrow_right_alt=پیکان راست جایگزین|arrow_up=پیکان بالا|arrow_up_alt=پیکان بالا جایگزین|arrow_warm_up=پیکان افزایش|attach_file=پیوست فایل|attach_file_add=افزودن پیوست|bookmark=نشانک|bookmark_add=افزودن نشانک|bookmark_added=نشانک افزوده‌شده|bookmark_check=تأیید نشانک|bookmark_heart=نشانک محبوب|bookmark_remove=حذف نشانک|bookmark_star=نشانک ستاره‌دار|brightness_alert=هشدار روشنایی|calendar=تقویم|check=تأیید|chess_bishop=فیل شطرنج|chess_knight=اسب شطرنج|chess_pawn=سرباز شطرنج|chess_queen=وزیر شطرنج|chess_rook=رخ شطرنج|chevron_down=زاویه پایین|chevron_left=زاویه چپ|chevron_right=زاویه راست|chevron_up=زاویه بالا|close=بستن|close_small=بستن کوچک|cloud_download=دانلود از ابر|cloud_upload=آپلود به ابر|crown=تاج|dark_mode=حالت تیره|download=دانلود|downloading=در حال دانلود|edit=ویرایش|edit_square=ویرایش در کادر|extension=افزونه|fingerprint=اثر انگشت|help=راهنما|home=خانه|id_card=کارت شناسایی|image=تصویر|image_arrow_up=آپلود تصویر|image_search=جست‌وجوی تصویر|imagesearch_roller=غلتک جست‌وجوی تصویر|imagesmode=حالت تصاویر|leaderboard=جدول رتبه‌بندی|light_mode=حالت روشن|link=پیوند|link_2=پیوند دوم|link_off=قطع پیوند|location=مکان|mail=ایمیل|menu=منو|more_horizontal=بیشتر افقی|more_vertical=بیشتر عمودی|motion_play=پخش حرکت|my_location=مکان من|notifications=اعلان‌ها|pause_circle=توقف موقت دایره‌ای|person=شخص|phone_enabled=تماس تلفنی|play_arrow=پخش|play_circle=پخش دایره‌ای|poker_chip=ژتون پوکر|release_alert=هشدار انتشار|scoreboard=تابلوی امتیاز|share=اشتراک‌گذاری|shoe_cleats=کفش ورزشی|sports=ورزش|sports_esports=ورزش الکترونیک|stadia_controller=دسته استیدیا|star=ستاره|star_half=نیم‌ستاره|store=فروشگاه|tactic=تاکتیک|target_check=هدف تأییدشده|thumb_down=نپسندیدن|thumb_up=پسندیدن|timer=زمان‌سنج|timer_play=شروع زمان‌سنج|trophy=جام|upload=آپلود|verified=تأییدشده|video_camera_back=دوربین پشت|video_camera_back_add=افزودن دوربین پشت|video_camera_front=دوربین جلو|visibility=نمایش|visibility_off=پنهان‌کردن|warning=هشدار|workspace_premium_1=نشان ویژه یک|workspace_premium_2=نشان ویژه دو`;
const fa=Object.fromEntries(persian.split('|').map(s=>s.split('=')));
const pairs={
  iconSearch:['Search icon key, source name or label','جست‌وجوی شناسه، نام منبع یا نام آیکون'],
  iconLibraryCounts:['{logical} logical icons · {versions} artwork versions','{logical} مفهوم آیکون · {versions} نسخهٔ گرافیکی'],
  iconStyleRequired:['Icon-only buttons require Fill or Outline','دکمهٔ آیکونی به حالت توپر یا خطی نیاز دارد'],
  iconSizePreview:['Icon preview size','اندازهٔ پیش‌نمایش آیکون'],
  iconTint:['Icon tint','رنگ پیش‌نمایش آیکون'],
  originalArtwork:['Original artwork colors','رنگ‌های اصلی فایل'],
  themeTint:['Surface theme tint','رنگ متناسب با تم زمینه'],
  accentTint:['Accent tint','رنگ تأکیدی'],
  missingCounterpart:['Missing style: {style}','نسخهٔ موجود نیست: {style}'],
  iconRendered:['Validated by the SVG renderer','سازگاری با رندرر SVG تأیید شده'],
  iconExported:['Original SVG exported','SVG اصلی استخراج شد'],
  iconRenderPending:['Not yet rendered in this preview','هنوز در این پیش‌نمایش رندر نشده'],
  iconRenderFailed:['SVG rendering failed; source retained','رندر SVG ناموفق؛ فایل اصلی حفظ شده است'],
  iconLibraryStatus:['Development extraction · designer approval unavailable','استخراج توسعه‌ای · تأیید طراح موجود نیست'],
};
const fields={artworkSource:['Artwork source metadata','اطلاعات منبع آیکون'],logicalKey:['Logical icon key','شناسهٔ منطقی آیکون'],displayName:['Display name','نام نمایشی'],rawName:['Raw Figma name','نام اصلی Figma'],style:['Artwork style','سبک آیکون'],availableStyles:['Available styles','نسخه‌های موجود'],viewBox:['SVG viewBox','دستگاه مختصات SVG'],assetPath:['Package asset path','مسیر فایل در پکیج'],assetHash:['Original SHA-256','هش SHA-256 اصلی'],sourceColors:['Original SVG paints','رنگ‌های اصلی SVG'],bindings:['Original source bindings','اتصال‌های اصلی منبع'],previewSize:['Current preview extent','اندازهٔ پیش‌نمایش فعلی'],tint:['Current tint','رنگ اعمال‌شدهٔ فعلی'],semanticLabel:['Semantic label','برچسب دسترس‌پذیری'],decorative:['Decorative','تزئینی'],extractionStatus:['Extraction status','وضعیت استخراج'],renderStatus:['Render status','وضعیت رندر'],issue:['Unresolved issue','مسئلهٔ حل‌نشده']};
for(const [language,index] of [['en',0],['fa',1]]) {
  const file=`apps/design_system_viewer/l10n/viewer/viewer_${language}.arb`;
  const arb=JSON.parse(fs.readFileSync(file));
  for(const [key,pair] of Object.entries(pairs)) {
    arb[key]=pair[index];arb['@'+key]={description:'Icon Viewer: '+key};
    if(key==='iconLibraryCounts')arb['@'+key].placeholders={logical:{type:'int'},versions:{type:'int'}};
    if(key==='missingCounterpart')arb['@'+key].placeholders={style:{type:'String'}};
  }
  arb.fieldLabel=mergeSelect(arb.fieldLabel,Object.fromEntries(Object.entries(fields).map(([k,v])=>[k,v[index]])),language==='fa'?'ناموجود':'Unavailable');
  arb.iconLabel='{icon, select, '+concepts.map(c=>{
    if(!fa[c.id])throw Error('Missing Persian label: '+c.id);
    return `${c.id}{${language==='fa'?fa[c.id]:c.rawName}}`;
  }).join(' ')+` other{${language==='fa'?'آیکون':'Icon'}}}`;
  arb['@iconLabel']={description:'Localized accessible icon concept names; technical IDs stay unchanged.',placeholders:{icon:{type:'String'}}};
  const output=JSON.stringify(arb,null,2)+'\n';
  if(process.argv.includes('--check')) {if(fs.readFileSync(file,'utf8')!==output)throw Error('Stale icon strings: '+file);}
  else fs.writeFileSync(file,output);
}
