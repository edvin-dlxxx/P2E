const fs=require('node:fs');
const entries={inspectorCopyAll:['Copy all','کپی همه'],inspectorCopyValue:['Copy','کپی'],inspectorCopied:['Copied to clipboard','در کلیپ‌بورد کپی شد']};
for(const [locale,index]of [['en',0],['fa',1]]){
 const file=`apps/design_system_viewer/l10n/viewer/viewer_${locale}.arb`;
 const arb=JSON.parse(fs.readFileSync(file));
 for(const [key,values]of Object.entries(entries)){arb[key]=values[index];arb['@'+key]={description:'Inspector clipboard: '+key};}
 const data=JSON.stringify(arb,null,2)+'\n';
 if(process.argv.includes('--check')){if(fs.readFileSync(file,'utf8')!==data)throw Error('Stale Inspector strings '+locale);}
 else fs.writeFileSync(file,data);
}
