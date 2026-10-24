const fs=require('node:fs');
const strings={
  appBarCompactPoints:['Compact points (caller data)','امتیاز فشرده (دادهٔ مصرف‌کننده)'],appBarCompactCoins:['Compact coins (caller data)','سکهٔ فشرده (دادهٔ مصرف‌کننده)'],
  appBarTitle:['App Bar','نوار بالای صفحه'],appBarHome:['Home','خانه'],appBarGame:['Downloadable Game','بازی دانلودی'],appBarBack:['Back','بازگشت'],
  appBarSource:['Source reference · English LTR','مرجع منبع · انگلیسی LTR'],appBarLocalized:['Localized runtime','اجرای بومی‌سازی‌شده'],
  appBarCount:['{count} of 5 source variants · 3 categories','{count} از ۵ واریانت منبع · ۳ دسته'],
  appBarMissing:['Back Light: unavailable — no source variant','بازگشت روشن: ناموجود؛ واریانت منبع ندارد'],
  appBarPolicy:['64 content + host-owned top inset. Flexible space → supplied compact values → visible horizontal scroll. Transparent source surface.','محتوای ۶۴ + inset بالای متعلق به میزبان. فضای منعطف ← مقادیر فشردهٔ مصرف‌کننده ← پیمایش افقی آشکار. سطح منبع شفاف است.'],
  appBarAvatar:['Avatar text','متن آواتار'],appBarPoints:['Points display','نمایش امتیاز'],appBarUnit:['Points unit','واحد امتیاز'],appBarCoins:['Coins display','نمایش سکه'],
  appBarProfile:['Profile','پروفایل'],appBarHelp:['Help','راهنما'],appBarDownloads:['Downloads','دانلودها'],appBarNotificationLabel:['Downloads, new activity','دانلودها، فعالیت جدید'],
  appBarBookmark:['Bookmark','نشانک'],appBarAddCoins:['Add coins','افزودن سکه'],appBarNotification:['Notification dot','نقطهٔ اعلان'],
  appBarCompact:['Supply compact values','ارائهٔ مقادیر فشرده'],appBarLong:['Long balance example','نمونهٔ موجودی طولانی'],
  appBarUnavailableActions:['Unavailable actions','عملیات ناموجود'],appBarFeedback:['Local action counts: {value}','تعداد عملیات محلی: {value}'],
  appBarPreviewWidth:['Content width','عرض محتوا'],appBarUnitSample:['pts','امتیاز'],appBarCategory:['Category','دسته'],
  appBarPointsMeaning:['{value} {unit}','{value} {unit}'],appBarCoinsMeaning:['{value} coins','{value} سکه']
};
for(const [locale,index] of [['en',0],['fa',1]]){
  const p=`apps/design_system_viewer/l10n/viewer/viewer_${locale}.arb`,a=JSON.parse(fs.readFileSync(p));
  for(const [key,values] of Object.entries(strings)){a[key]=values[index];a['@'+key]={description:'App Bar Viewer: '+key};}
  a['@appBarCount'].placeholders={count:{type:'int'}};
  for(const key of ['appBarFeedback','appBarCoinsMeaning'])a['@'+key].placeholders={value:{type:'String'}};
  a['@appBarPointsMeaning'].placeholders={value:{type:'String'},unit:{type:'String'}};
  const data=JSON.stringify(a,null,2)+'\n';
  if(process.argv.includes('--check')){if(fs.readFileSync(p,'utf8')!==data)throw Error('Stale '+p);}else fs.writeFileSync(p,data);
}
