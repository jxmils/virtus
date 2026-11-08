# Virtus artwork direction

The approved direction is pale, matte marble and restrained classical painted colour on pure black. No golden or bronze figures, sepia grading, glowing rims or fantasy armour. Faces and drapery should remain visible under the app's quote overlays.

`docs/artwork-prompts.json` contains each exact production prompt and generator. The November refresh uses the built-in image generator. Sixteen distinct images supply fourteen shared themes and three author overrides; Leonidas shares the Spartan theme image.

## Composition

Portrait 4:5, a single figure shown from the whole head to torso or upper thighs. Leave black space above the head and along the right edge. Use neutral soft lighting, fine natural stone texture and dignified expressions. Painted variants use muted plum, sage, indigo and charcoal with natural skin. Never bake text, quotes, signatures or interface elements into the artwork.

The shared figures illustrate themes; they are not claimed likenesses of every author assigned to them. Named author overrides take priority. The olive branch remains the fallback for newly added authors, now carved in white marble.

## Production and verification

Preserve originals and lossless generated masters outside the app bundle in `../Artwork and Verification/marble-refresh-20261103/`. Export the selected PNG masters to JPEG quality 88 with macOS sips, without recolouring or cropping. Keep stable filenames in `Portraits/` so the app and widget continue using the same resource mapping.

Run `Tools/check.sh` and inspect the actual Today, share-card, widget and artwork-gallery renders. The prompts alone do not establish complete delivery: compare the production files against the saved generated masters and record hashes in the refresh receipt.
