# Virtus portrait prompt

Keep the STYLE block identical for every image. Change only the SUBJECT line.
Save each result as `Portraits/<author-slug>.jpg`, 4:5 (1080x1350 or larger), e.g. `marcus-aurelius.jpg`.

## Master prompt

```
SUBJECT: <one line from the list below>

STYLE: dark cinematic portrait, hyper-realistic, museum-grade bronze and marble textures, battle-worn metal
with fine scratches and patina, muted crimson cloak. Pure black background (#000000), no set, no props,
no text. Single hard key light from the upper left, soft rim light on the far edge, deep chiaroscuro,
most of the figure falls into shadow. Three-quarter profile, head and shoulders, looking off-frame to
the right, calm and resolute expression. Subject fills the left 45% of the frame; the right 55% is
empty black for text. 85mm lens, shallow depth of field, f/2. Colour grade: near-monochrome, warm
bronze highlights, cold black shadows, slight film grain, no bloom. Portrait 4:5.
```

Negative prompt (where the tool has one):
```
text, watermark, logo, caption, frame, border, bright background, daylight, colourful, cartoon, anime,
painting strokes, smile, full body, multiple people, modern clothing, blurry, low contrast
```

Tool notes: Midjourney add `--ar 4:5 --style raw --stylize 150` and reuse one `--sref` from your first
good image so the look stays locked. DALL-E / ChatGPT: paste as is, ask for "no text in the image".
Stable Diffusion: CFG 5-6, 30 steps, keep the same seed across subjects.

Marble variant (for Greeks and Romans, like the Alexander bust reference): replace the first sentence of
STYLE with "dark cinematic portrait of a white marble statue, hyper-realistic weathered Carrara marble
with small chips and veining" and drop the crimson cloak.

## Subject lines

marcus-aurelius     Marcus Aurelius, Roman emperor, curly hair and full philosopher's beard, bronze cuirass
seneca              Seneca, elderly Roman Stoic, lined face, short white hair, plain toga
epictetus           Epictetus, bearded Greek Stoic in a rough wool cloak, calm weathered face
leonidas            Leonidas, Spartan king in a Corinthian bronze helmet with a horsehair crest, crimson cloak, round shield
alexander-the-great Alexander the Great, young, clean-shaven, thick wavy lion's-mane hair, slight upward gaze
julius-caesar       Julius Caesar, gaunt middle-aged Roman, receding hair, laurel wreath, red cloak
augustus            Augustus, young Roman emperor, short combed hair, calm imperial bearing
cicero              Cicero, elderly Roman statesman, thin face, toga, intelligent eyes
hannibal            Hannibal, Carthaginian general, dark beard, bronze helmet, one eye in shadow
pericles            Pericles, Athenian statesman, Corinthian helmet pushed back on his head, full beard
socrates            Socrates, snub nose, broad face, unkempt beard, bald, simple cloak
plato               Plato, broad-shouldered Greek philosopher, full beard, headband
aristotle           Aristotle, Greek philosopher, short beard, sharp eyes, himation
diogenes            Diogenes, wild-bearded Greek cynic, sunburnt, ragged cloak
heraclitus          Heraclitus, brooding Greek philosopher, dark beard, deep shadows
sun-tzu             Sun Tzu, ancient Chinese general, lamellar bronze armour, thin beard, topknot
confucius           Confucius, elderly Chinese sage, long grey beard, scholar's robe
lao-tzu             Lao Tzu, very old Chinese sage, long white beard and eyebrows, serene
miyamoto-musashi    Miyamoto Musashi, ronin swordsman, unkempt hair, dark kimono, two swords at his belt
genghis-khan        Genghis Khan, Mongol emperor, fur-trimmed helmet, braided beard, piercing eyes
napoleon-bonaparte  Napoleon Bonaparte, bicorne hat, dark military coat with high collar, hand in coat
frederick-the-great Frederick the Great, Prussian king, powdered hair, dark military coat, stern
george-washington   George Washington, powdered hair, dark coat, resolute jaw
abraham-lincoln     Abraham Lincoln, gaunt lined face, chin beard, dark coat
theodore-roosevelt  Theodore Roosevelt, round spectacles, thick moustache, rough rider hat
winston-churchill   Winston Churchill, bulldog face, bow tie, cigar, bowler hat in shadow
george-s-patton     George S. Patton, steel helmet with stars, hard jaw, leather jacket
niccolo-machiavelli Niccolò Machiavelli, Florentine, black cap and robe, thin knowing face
leonardo-da-vinci   Leonardo da Vinci, old master with long white beard and hair, dark cloak
michelangelo        Michelangelo, broken nose, short grey beard, dusty work clothes
william-shakespeare William Shakespeare, high forehead, small beard, Elizabethan collar
friedrich-nietzsche Friedrich Nietzsche, enormous moustache, swept-back hair, intense stare
arthur-schopenhauer Arthur Schopenhauer, old, wild white side hair, high collar, sardonic
johann-wolfgang-von-goethe Goethe, old poet, white hair, dark coat, wide collar
ralph-waldo-emerson Ralph Waldo Emerson, long thin face, high collar, 19th-century coat
henry-david-thoreau Henry David Thoreau, neck beard, plain coat, clear eyes
leo-tolstoy         Leo Tolstoy, old, huge white beard, peasant shirt
fyodor-dostoevsky   Fyodor Dostoevsky, thin beard, deep-set haunted eyes, dark coat
bruce-lee           Bruce Lee, bare shoulders, taut muscles, intense focused eyes, sweat
muhammad-ali        Muhammad Ali, boxing gloves raised, towel over shoulder, defiant
vince-lombardi      Vince Lombardi, glasses, fedora, overcoat, set jaw
viktor-frankl       Viktor Frankl, round glasses, thin, kind serious face
albert-camus        Albert Camus, trench coat collar up, cigarette, swept hair
