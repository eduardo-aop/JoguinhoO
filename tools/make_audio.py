import math, random, wave, struct
from pathlib import Path
root=Path(__file__).resolve().parents[1]/'assets/audio'
root.mkdir(parents=True,exist_ok=True)
random.seed(91)
for name,duration in [('swing',.23),('hit',.16),('block',.22),('cast',.36),('step',.08),('rune',.5),('death',.42)]:
    rate=22050; samples=[]
    for i in range(int(rate*duration)):
        t=i/rate; u=t/duration
        noise=random.uniform(-1,1)
        envelope=math.sin(math.pi*min(1,u*10))*math.exp(-u*4) if u < .1 else math.exp(-u*4)
        if name=='swing': v=noise*.30*math.sin(math.pi*u)**2
        elif name=='hit': v=(math.sin(2*math.pi*(95*t-55*t*t))*.7+noise*.3)*envelope
        elif name=='block': v=(math.sin(2*math.pi*780*t)+math.sin(2*math.pi*1180*t)*.4+noise*.2)*envelope*.36
        elif name=='cast': v=(math.sin(2*math.pi*(260*t+430*t*t))*.35+noise*.13)*math.sin(math.pi*u)
        elif name=='step': v=(noise*.35+math.sin(2*math.pi*120*t)*.25)*envelope
        elif name=='rune': v=(math.sin(2*math.pi*660*t)+math.sin(2*math.pi*880*t)*.5)*math.sin(math.pi*u)*.22
        else: v=(math.sin(2*math.pi*(180*t-130*t*t))*.35+noise*.13)*envelope
        samples.append(int(max(-.85,min(.85,v))*32767))
    with wave.open(str(root/(name+'.wav')),'wb') as f:
        f.setnchannels(1);f.setsampwidth(2);f.setframerate(rate);f.writeframes(struct.pack('<'+'h'*len(samples),*samples))
print('7 original synthesized audio effects saved')
