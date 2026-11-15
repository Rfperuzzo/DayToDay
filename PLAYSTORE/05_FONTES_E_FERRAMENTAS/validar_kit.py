"""Local structural validation, using only the Python standard library."""
from pathlib import Path
import json,struct,hashlib

root=Path(__file__).resolve().parents[1]
images=root/'02_VISUAIS/ENVIAR_NO_CONSOLE'
results=[]
for path in sorted(images.glob('*.png')):
 data=path.read_bytes();assert data[:8]==b'\x89PNG\r\n\x1a\n',path
 w,h,depth,color,_,_,_=struct.unpack('>IIBBBBB',data[16:29])
 if path.name.startswith('icone'):
  assert (w,h,depth,color)==(512,512,8,6) and len(data)<=1024*1024,path
 elif path.name.startswith('destaque'):
  assert (w,h,depth,color)==(1024,500,8,2),path
 else:
  assert (w,h,depth,color)==(1080,1920,8,2),path
  assert 320<=min(w,h) and max(w,h)<=3840 and max(w,h)<=2*min(w,h),path
 results.append({'file':path.relative_to(root).as_posix(),'width':w,'height':h,'bitDepth':depth,'pngColorType':color,'bytes':len(data),'sha256':hashlib.sha256(data).hexdigest()})
assert len(results)==8
lengths={}
for name,maximum in [('titulo.txt',30),('descricao-curta.txt',80),('descricao-completa.txt',4000)]:
 text=(root/'01_TEXTOS/pt-BR'/name).read_text(encoding='utf-8').strip();lengths[name]=len(text)
 assert 0<len(text)<=maximum,(name,len(text))
notes=(root/'01_TEXTOS/pt-BR/notas-versao.txt').read_text(encoding='utf-8').strip()
assert notes.startswith('<pt-BR>') and notes.endswith('</pt-BR>') and len(notes)<500
alt=json.loads((root/'02_VISUAIS/ORDEM_E_TEXTOS_ALTERNATIVOS.json').read_text(encoding='utf-8'))
assert len(alt)==6 and all(len(x['alt'])<=140 and (images/x['arquivo']).exists() for x in alt)
contact=json.loads((root/'01_TEXTOS/DADOS_DA_FICHA.json').read_text(encoding='utf-8'))
assert contact['support_email']=='thalesmelodasilva@gmail.com'
for ext in ['*.jks','*.keystore','*.p12','key.properties']:
 assert not list(root.rglob(ext)),f'Signing secret inside kit: {ext}'
privacy=(root/'03_POLITICAS_E_DECLARACOES/PRIVACIDADE.md').read_text(encoding='utf-8')
assert 'desativar atividades' in privacy and 'excluir atividades' not in privacy
report={'date':'2026-11-15','packChecksPassed':True,'readyToPublish':False,'textLengths':lengths,'images':results,
 'publicationPending':['Upload signing key/certificate','Public privacy URL and access inside app','Restricted-permission declarations/eligibility','Play Console forms and required physical/pre-launch tests']}
(root/'06_VALIDACAO').mkdir(exist_ok=True)
(root/'06_VALIDACAO/VALIDACAO_DO_KIT.json').write_text(json.dumps(report,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
print(json.dumps({'packChecksPassed':True,'readyToPublish':False,'images':len(results),'textLengths':lengths},ensure_ascii=False))
