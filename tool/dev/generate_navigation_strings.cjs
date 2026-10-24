const fs=require('node:fs');
const strings={
 navBadgeEmpty:['Enter badge text or turn the badge off.','متن نشان را وارد کنید یا نشان را غیرفعال کنید.'],
 navTitle:['Navigator Bar','نوار پیمایش'],navSources:['Source bars · 2 variants','نوارهای منبع · ۲ واریانت'],navItems:['Nested items · 4 source states','آیتم‌های داخلی · ۴ حالت منبع'],
 navLive:['Controlled selection example','نمونهٔ انتخاب کنترل‌شده'],navHome:['Home','خانه'],navMission:['Mission','مأموریت'],navGames:['Games','بازی‌ها'],navLeaderboard:['Leaderboard','جدول رتبه‌بندی'],navShop:['Shop','فروشگاه'],
 navSelected:['Selected destination','مقصد انتخاب‌شده'],navWidth:['Preview width','عرض پیش‌نمایش'],navInset:['Simulated bottom inset','شبیه‌سازی inset پایین'],navBadge:['Notification badge','نشان اعلان'],navBadgeText:['Badge display','متن نشان'],
 navBadgeMeaning:['{destination}: {badge} notifications','{destination}: اعلان {badge}'],navCount:['{bars} of 2 source bars · {items} of 4 nested item states','{bars} از ۲ نوار منبع · {items} از ۴ حالت داخلی'],
 navFeedback:['Last emitted ID: {id} · activations: {count}','آخرین ID ارسال‌شده: {id} · تعداد فعال‌سازی: {count}'],
 navNotice:['Source references remain English LTR at 402 / 1.0. Controls below configure the runtime example. Selection, labels and badges are caller data; no routing.','مراجع منبع انگلیسی و LTR با عرض ۴۰۲ و مقیاس ۱ هستند. کنترل‌ها نمونهٔ اجرایی را تغییر می‌دهند. انتخاب، عنوان‌ها و نشان‌ها دادهٔ مصرف‌کننده‌اند؛ مسیریابی انجام نمی‌شود.'],
 navPolicy:['Five equal cells; minimum width 252. Labels wrap and content height grows; no hidden destinations or scrolling navigation. Bottom safe area belongs to the host adapter.','پنج خانهٔ مساوی؛ حداقل عرض ۲۵۲. عنوان‌ها چندخطی و ارتفاع محتوا بیشتر می‌شود؛ مقصدی مخفی نمی‌شود و نوار پیمایش اسکرول ندارد. safe area پایین متعلق به adapter میزبان است.'],
 navUnavailable:['Unavailable callbacks','callbackهای غیرفعال'],navNoAction:['None','هیچ‌کدام'],navLong:['Long labels and badge example','نمونهٔ عنوان و نشان طولانی'],
 navLongLabel:['Long destination label','عنوان طولانی مقصد آزمایشی'],navSourceItem:['Nested source item','آیتم داخلی منبع'],navSourceBar:['Source bar','نوار منبع'],
 navTypography:['Source-unlinked component typography; Persian uses provisional Vazirmatn (R-003).','typography کامپوننت به Text Style منبع متصل نیست؛ فارسی از Vazirmatn موقت استفاده می‌کند (R-003).']
};
for(const [locale,i]of [['en',0],['fa',1]]){
 const p=`apps/design_system_viewer/l10n/viewer/viewer_${locale}.arb`,a=JSON.parse(fs.readFileSync(p));
 for(const [k,v]of Object.entries(strings)){a[k]=v[i];a['@'+k]={description:'Navigator Bar Viewer: '+k};}
 a['@navCount'].placeholders={bars:{type:'int'},items:{type:'int'}};
 a['@navFeedback'].placeholders={id:{type:'String'},count:{type:'int'}};
 a['@navBadgeMeaning'].placeholders={destination:{type:'String'},badge:{type:'String'}};
 const data=JSON.stringify(a,null,2)+'\n';if(process.argv.includes('--check')){if(fs.readFileSync(p,'utf8')!==data)throw Error('Stale '+p);}else fs.writeFileSync(p,data);
}
