const fs=require('node:fs');
const strings={badgeCount:['{count} of {total} Badge source variants','{count} از {total} واریانت منبع نشان'],badgeReference:['Source reference text','متن مرجع منبع'],badgeLocalized:['Localized sample text','متن نمونهٔ ترجمه‌شده'],badgeShort:['New','جدید'],badgeLong:['A longer status label that wraps when space is limited','عنوان طولانی وضعیت که در فضای محدود در چند خط نمایش داده می‌شود'],badgeGeometryNote:['Source includes a 1-unit nested label border; 84 × 24 is preserved.','منبع یک بوردر ۱ واحدی در قاب متن دارد؛ اندازهٔ ۸۴ × ۲۴ حفظ شده است.'],badgePreviewNotice:['Presentational Badge; preview options do not add source variants.','نشان نمایشی است؛ گزینه‌های پیش‌نمایش واریانت منبع جدید ایجاد نمی‌کنند.']};
for(const [locale,index]of [['en',0],['fa',1]]){
 const file=`apps/design_system_viewer/l10n/viewer/viewer_${locale}.arb`,a=JSON.parse(fs.readFileSync(file));
 for(const [key,values]of Object.entries(strings)){a[key]=values[index];a['@'+key]={description:'Badge Viewer: '+key};}
 a['@badgeCount'].placeholders={count:{type:'int'},total:{type:'int'}};
 const data=JSON.stringify(a,null,2)+'\n';if(process.argv.includes('--check')){if(fs.readFileSync(file,'utf8')!==data)throw Error('Stale Badge strings '+locale);}else fs.writeFileSync(file,data);
}
