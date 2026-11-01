from reportlab.lib import colors
from reportlab.lib.colors import HexColor
from reportlab.lib.enums import TA_CENTER, TA_LEFT
from reportlab.lib.pagesizes import A4, landscape
from reportlab.lib.styles import getSampleStyleSheet, ParagraphStyle
from reportlab.lib.units import mm
from reportlab.platypus import SimpleDocTemplate, Paragraph, Spacer, Table, TableStyle, PageBreak, Image, KeepTogether
from reportlab.pdfbase.ttfonts import TTFont
from reportlab.pdfbase import pdfmetrics
from reportlab.lib.utils import ImageReader
from reportlab.pdfgen.canvas import Canvas
import os

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), '..'))
OUT = os.path.join(ROOT, 'output', 'pdf', 'davao_chronicles_game_plan.pdf')
os.makedirs(os.path.dirname(OUT), exist_ok=True)

PAGE_W, PAGE_H = landscape(A4)
INK = HexColor('#17212B')
MUTED = HexColor('#5B6873')
PAPER = HexColor('#F7F3EA')
TEAL = HexColor('#0F766E')
GOLD = HexColor('#D99A22')
CORAL = HexColor('#D95D39')
BLUE = HexColor('#3B82A0')
GREEN = HexColor('#5F8D54')
LIGHT_TEAL = HexColor('#E1F0ED')
LIGHT_GOLD = HexColor('#FFF0C7')
LIGHT_CORAL = HexColor('#F8DFD5')
LIGHT_BLUE = HexColor('#DDECF2')
WHITE = colors.white

styles = getSampleStyleSheet()
styles.add(ParagraphStyle(name='CoverTitle', parent=styles['Title'], fontName='Helvetica-Bold', fontSize=31, leading=34, textColor=WHITE, alignment=TA_LEFT, spaceAfter=8))
styles.add(ParagraphStyle(name='CoverSub', parent=styles['Normal'], fontName='Helvetica', fontSize=13, leading=17, textColor=HexColor('#D9F0ED')))
styles.add(ParagraphStyle(name='H1x', parent=styles['Heading1'], fontName='Helvetica-Bold', fontSize=21, leading=24, textColor=INK, spaceAfter=7))
styles.add(ParagraphStyle(name='H2x', parent=styles['Heading2'], fontName='Helvetica-Bold', fontSize=12, leading=14, textColor=TEAL, spaceAfter=3))
styles.add(ParagraphStyle(name='Bodyx', parent=styles['BodyText'], fontName='Helvetica', fontSize=8.5, leading=11.2, textColor=INK))
styles.add(ParagraphStyle(name='Smallx', parent=styles['BodyText'], fontName='Helvetica', fontSize=7.1, leading=9.2, textColor=MUTED))
styles.add(ParagraphStyle(name='CardTitle', parent=styles['BodyText'], fontName='Helvetica-Bold', fontSize=9.5, leading=11.5, textColor=INK))
styles.add(ParagraphStyle(name='CardText', parent=styles['BodyText'], fontName='Helvetica', fontSize=7.4, leading=9.3, textColor=INK))
styles.add(ParagraphStyle(name='Tiny', parent=styles['BodyText'], fontName='Helvetica', fontSize=6.7, leading=8.1, textColor=INK))

def P(text, style='Bodyx'):
    return Paragraph(text, styles[style])

def footer(canvas, doc):
    canvas.saveState()
    canvas.setStrokeColor(HexColor('#D7D0C0'))
    canvas.line(15*mm, 11*mm, PAGE_W-15*mm, 11*mm)
    canvas.setFont('Helvetica', 7)
    canvas.setFillColor(MUTED)
    canvas.drawString(15*mm, 6.5*mm, 'Davao Chronicles | Production planning guide')
    canvas.drawRightString(PAGE_W-15*mm, 6.5*mm, f'{doc.page}')
    canvas.restoreState()

def card(title, body, bg=WHITE, width=53*mm, accent=TEAL):
    t = Table([[P(title, 'CardTitle')], [P(body, 'CardText')]], colWidths=[width])
    t.setStyle(TableStyle([
        ('BACKGROUND',(0,0),(-1,-1),bg), ('BOX',(0,0),(-1,-1),0.7,HexColor('#D6D0C4')),
        ('LINEBEFORE',(0,0),(0,-1),3,accent), ('LEFTPADDING',(0,0),(-1,-1),7),
        ('RIGHTPADDING',(0,0),(-1,-1),7), ('TOPPADDING',(0,0),(-1,0),6),
        ('BOTTOMPADDING',(0,0),(-1,0),2), ('TOPPADDING',(0,1),(-1,-1),2),
        ('BOTTOMPADDING',(0,1),(-1,-1),6),
    ]))
    return t

def bullets(items, style='CardText'):
    return '<br/>'.join(['&#8226; ' + x for x in items])

def stage_image(n, w=54*mm, h=30*mm):
    path = os.path.join(ROOT, 'src', 'assets', 'gfx', 'sprites', f'stage{n}_' + ['ancient_trading_gulf','spanish_expedition','plantation_era','wwii_liberation','changing_davao'][n-1] + '_640x360.png')
    if os.path.exists(path):
        return Image(path, width=w, height=h)
    return Spacer(w, h)

story = []

# Cover
story.append(Spacer(1, 16*mm))
cover = Table([[P('DAVAO CHRONICLES', 'CoverTitle'), P('GAME PLAN', 'CoverTitle')], [P('A visual build guide for a 32-bit-style historical platformer set across Davao\'s changing eras.', 'CoverSub'), '']], colWidths=[110*mm, 65*mm])
cover.setStyle(TableStyle([('BACKGROUND',(0,0),(-1,-1),TEAL),('TEXTCOLOR',(0,0),(-1,-1),WHITE),('LEFTPADDING',(0,0),(-1,-1),14),('RIGHTPADDING',(0,0),(-1,-1),14),('TOPPADDING',(0,0),(-1,-1),14),('BOTTOMPADDING',(0,0),(-1,-1),14),('SPAN',(0,1),(1,1))]))
story.append(cover)
story.append(Spacer(1, 10*mm))
story.append(P('The player runs, jumps, fights, and learns through five chapters of Davao history. This document turns the planning notes into an actionable content map: what to build, what is already signposted in the project, and what still needs a design decision.', 'Bodyx'))
story.append(Spacer(1, 7*mm))
story.append(Table([[card('CORE LOOP', 'Choose a level and costume -> traverse hazards -> collect cacao and buffs -> defeat the boss -> earn stars -> return to menu.', LIGHT_TEAL, 78*mm, TEAL), card('TARGET SESSION', 'Each level should take at least 1 minute, including obstacle navigation and the boss encounter.', LIGHT_GOLD, 78*mm, GOLD), card('PLAYER STATE', 'Start with 3 hearts. Lose by falling into gaps or reaching 0 hearts. Win by reaching the end.', LIGHT_CORAL, 78*mm, CORAL)]], colWidths=[82*mm,82*mm,82*mm], style=TableStyle([('VALIGN',(0,0),(-1,-1),'TOP'),('LEFTPADDING',(0,0),(-1,-1),0),('RIGHTPADDING',(0,0),(-1,-1),4)])))
story.append(Spacer(1, 7*mm))
story.append(P('Build focus: establish a reusable runner/combat framework, then swap the historical setting, hazard kit, enemy kit, and story beat for each level.', 'H2x'))
story.append(PageBreak())

# At a glance
story.append(P('01 | THE BUILD MAP', 'H1x'))
story.append(P('Five eras, one shared gameplay grammar. The strongest production shortcut is to build the common systems once, then author level-specific content as data and scenes.', 'Bodyx'))
story.append(Spacer(1, 5*mm))
stages = [
    ('1', 'Ancient Trading Gulf', 'Pre-colonial trade', 'Jumping + natural hazards', 'Easy', TEAL),
    ('2', 'Spanish Expedition', '1848 conquest and resistance', 'Projectiles + barricades', 'Easy-Medium', GOLD),
    ('3', 'Plantation Era', 'Abaca growth + Little Tokyo', 'Moving obstacles + timed platforms', 'Medium', CORAL),
    ('4', 'WWII and Liberation', '1941-1945 wartime Davao', 'Stealth + projectiles + hazards', 'Hard', BLUE),
    ('5', 'A Changing Davao', 'Modern growth and communities', 'Combined mechanics + speed', 'Very Hard', GREEN),
]
rows = [[P('<font color="#FFFFFF">LEVEL</font>', 'CardTitle'), P('<font color="#FFFFFF">SETTING / HISTORY</font>', 'CardTitle'), P('<font color="#FFFFFF">SIGNATURE MECHANIC</font>', 'CardTitle'), P('<font color="#FFFFFF">DIFFICULTY</font>', 'CardTitle')]]
for n, title, hist, mech, diff, col in stages:
    rows.append([P(f'<font color="{col.hexval()}"><b>{n}</b></font>', 'CardTitle'), P(f'<b>{title}</b><br/><font color="#5B6873">{hist}</font>', 'CardText'), P(mech, 'CardText'), P(diff, 'CardText')])
t = Table(rows, colWidths=[18*mm, 78*mm, 82*mm, 35*mm], rowHeights=[9*mm]+[16*mm]*5)
t.setStyle(TableStyle([('BACKGROUND',(0,0),(-1,0),INK),('TEXTCOLOR',(0,0),(-1,0),WHITE),('GRID',(0,0),(-1,-1),0.5,HexColor('#D6D0C4')),('VALIGN',(0,0),(-1,-1),'MIDDLE'),('LEFTPADDING',(0,0),(-1,-1),7),('RIGHTPADDING',(0,0),(-1,-1),7),('BACKGROUND',(0,1),(-1,-1),WHITE)]))
story.append(t)
story.append(Spacer(1, 8*mm))
story.append(P('Shared systems to finish first', 'H2x'))
shared = [[card('MOVEMENT', bullets(['Run, jump, fall, coyote time', 'Moving platforms and water states']), LIGHT_BLUE, 55*mm, BLUE), card('COMBAT', bullets(['Health and damage feedback', 'Weapon attacks and enemy hit states']), LIGHT_CORAL, 55*mm, CORAL), card('PROGRESSION', bullets(['Cacao count and score', 'Stars, level completion, end screen']), LIGHT_GOLD, 55*mm, GOLD), card('PRESENTATION', bullets(['Title/date intro card', 'HUD, story labels, audio, transitions']), LIGHT_TEAL, 55*mm, TEAL)]]
story.append(Table(shared, colWidths=[60*mm]*4, style=TableStyle([('VALIGN',(0,0),(-1,-1),'TOP'),('LEFTPADDING',(0,0),(-1,-1),0),('RIGHTPADDING',(0,0),(-1,-1),4)])))
story.append(Spacer(1, 6*mm))
story.append(P('Existing project signals: five level scenes, stage background art, player class scripts for urban / Bagobo / Ata, collectible cacao, health/lives UI, time-limit UI, enemy behavior components, and end-screen star/score display are already present in the repository.', 'Smallx'))
story.append(PageBreak())

# Characters
story.append(P('02 | CHARACTERS, COSTUMES, AND ABILITIES', 'H1x'))
story.append(P('Treat costumes as readable playstyle choices. Every character needs a clear baseline attack, one signature action, and a buff that changes moment-to-moment decisions.', 'Bodyx'))
story.append(Spacer(1, 5*mm))
char_rows = [
    [P('<font color="#FFFFFF">CHARACTER</font>', 'CardTitle'), P('<font color="#FFFFFF">WEAPON / SIGNATURE</font>', 'CardTitle'), P('<font color="#FFFFFF">BUFFS / COLORS</font>', 'CardTitle'), P('<font color="#FFFFFF">BUILD NOTES</font>', 'CardTitle')],
    [P('<b>Standard Urban</b>', 'CardText'), P('Baseline weapon / no special weapon specified.', 'CardText'), P('No special buff.', 'CardText'), P('Use as the control character for balance and onboarding.', 'CardText')],
    [P('<b>Ata of Paquibato</b>', 'CardText'), P('<b>Basket:</b> capture an enemy, throw it, deal damage.', 'CardText'), P('<b>White:</b> dodge all attacks for 3s<br/><b>Black:</b> reflect damage<br/><b>Red:</b> increase attack damage<br/><b>Blue:</b> restore HP<br/><b>Yellow:</b> Promise effect TBD', 'CardText'), P('Need a color selection UI and a final Yellow effect. Define capture rules, throw arc, and enemy compatibility.', 'CardText')],
    [P('<b>Bagobo-Tagabawa of Binugao</b>', 'CardText'), P('<b>Needle and Thread:</b> quick repeated pokes.<br/><b>Thread Snare:</b> immobilize an enemy temporarily.', 'CardText'), P('Thread Snare has a cooldown.', 'CardText'), P('Need cooldown length, targeting rules, visual telegraph, and whether snare works on bosses.', 'CardText')],
]
ct = Table(char_rows, colWidths=[43*mm, 66*mm, 76*mm, 67*mm], rowHeights=[9*mm, 23*mm, 43*mm, 32*mm])
ct.setStyle(TableStyle([('BACKGROUND',(0,0),(-1,0),INK),('TEXTCOLOR',(0,0),(-1,0),WHITE),('GRID',(0,0),(-1,-1),0.5,HexColor('#D6D0C4')),('VALIGN',(0,0),(-1,-1),'TOP'),('LEFTPADDING',(0,0),(-1,-1),7),('RIGHTPADDING',(0,0),(-1,-1),7),('TOPPADDING',(0,0),(-1,-1),6),('BACKGROUND',(0,1),(-1,-1),WHITE)]))
story.append(ct)
story.append(Spacer(1, 7*mm))
story.append(P('Ability design checklist', 'H2x'))
ability = [[card('INPUT', 'What button activates it? Is it tap, hold, or directional?', LIGHT_BLUE, 54*mm, BLUE), card('RESOURCE', 'Cooldown, inventory count, one-use flag, or passive?', LIGHT_GOLD, 54*mm, GOLD), card('FEEDBACK', 'Sound, animation, hit flash, status icon, and duration label.', LIGHT_CORAL, 54*mm, CORAL), card('BALANCE', 'What can it trivialize? What is its counterplay?', LIGHT_TEAL, 54*mm, TEAL)]]
story.append(Table(ability, colWidths=[59*mm]*4, style=TableStyle([('VALIGN',(0,0),(-1,-1),'TOP'),('LEFTPADDING',(0,0),(-1,-1),0),('RIGHTPADDING',(0,0),(-1,-1),4)])))
story.append(Spacer(1, 6*mm))
story.append(P('Art targets: urban, Ata, Bagobo, and enemy sprites are represented in the asset tree. Confirm the character-select portraits, costume-color variants, attack frames, hit frames, and ability VFX before content lock.', 'Smallx'))
story.append(PageBreak())

# Powerups
story.append(P('03 | POWER-UPS AND COLLECTIBLES', 'H1x'))
story.append(P('Power-ups should be visible decisions, not background noise. Give each one a distinct silhouette, pickup sound, HUD icon, and short status readout.', 'Bodyx'))
power_rows = [
    [P('<font color="#FFFFFF">ITEM</font>', 'CardTitle'), P('<font color="#FFFFFF">PLAYER EFFECT</font>', 'CardTitle'), P('<font color="#FFFFFF">DURATION / USE</font>', 'CardTitle'), P('<font color="#FFFFFF">IMPLEMENTATION CHECK</font>', 'CardTitle')],
    [P('<b>Durian</b>', 'CardText'), P('Throw: explode on impact and remove 1 enemy heart. Consume: restore 1 player heart.', 'CardText'), P('Stackable inventory.', 'CardText'), P('Need throw/consume choice, inventory counter, explosion radius, and pickup feedback.', 'CardText')],
    [P('<b>Cacao Beans</b>', 'CardText'), P('Increase weapon attack speed.', 'CardText'), P('3 seconds.', 'CardText'), P('Existing collectible and attack-speed signal found in project. Tune stacking and HUD status.', 'CardText')],
    [P('<b>Agila</b>', 'CardText'), P('Philippine Eagle slows the player\'s fall.', 'CardText'), P('One use.', 'CardText'), P('Need fall-state trigger, silhouette, and clear emergency-use affordance.', 'CardText')],
    [P('<b>Honey</b>', 'CardText'), P('Slows an enemy\'s movement.', 'CardText'), P('3 seconds; one use.', 'CardText'), P('Need target selection / hitbox rule and status effect on enemy.', 'CardText')],
    [P('<b>Kadayawan Combo</b>', 'CardText'), P('Multiple buffs increase score multiplier.', 'CardText'), P('Tentative.', 'CardText'), P('Decide combo window, multiplier curve, reset rule, and UI callout.', 'CardText')],
]
pt = Table(power_rows, colWidths=[40*mm, 82*mm, 43*mm, 87*mm], rowHeights=[9*mm, 25*mm, 19*mm, 19*mm, 19*mm, 21*mm])
pt.setStyle(TableStyle([('BACKGROUND',(0,0),(-1,0),INK),('TEXTCOLOR',(0,0),(-1,0),WHITE),('GRID',(0,0),(-1,-1),0.5,HexColor('#D6D0C4')),('VALIGN',(0,0),(-1,-1),'TOP'),('LEFTPADDING',(0,0),(-1,-1),7),('RIGHTPADDING',(0,0),(-1,-1),7),('TOPPADDING',(0,0),(-1,-1),6),('BACKGROUND',(0,1),(-1,-1),WHITE)]))
story.append(pt)
story.append(Spacer(1, 7*mm))
story.append(P('Scoring and rewards', 'H2x'))
story.append(Table([[card('CACAO', 'Collectibles score points and can drive the multiplier. Project code currently uses 100 points per collectible and awards a new life every 10 collected.', LIGHT_GOLD, 74*mm, GOLD), card('STARS', 'Target rule from the plan: 15 cacao = 3 stars; 10-14 = 2; 5-9 = 1; below 5 = 0. Validate the exact thresholds against level collectible counts.', LIGHT_TEAL, 74*mm, TEAL), card('COMPLETION', 'All cacao plus boss defeat should produce a premium result: 3 stars or a Davao element. Choose one reward language and use it consistently.', LIGHT_CORAL, 74*mm, CORAL)]], colWidths=[79*mm]*3, style=TableStyle([('VALIGN',(0,0),(-1,-1),'TOP'),('LEFTPADDING',(0,0),(-1,-1),0),('RIGHTPADDING',(0,0),(-1,-1),4)])))
story.append(PageBreak())

# Levels pages
story.append(P('04 | LEVELS 1-3: BUILD THE ERA KITS', 'H1x'))
story.append(P('Each level is a compact content bundle: background, hazard vocabulary, enemy mix, collectible route, boss beat, and one historical story label.', 'Bodyx'))
story.append(Spacer(1, 4*mm))
level_data = [
    (1, 'The Ancient Trading Gulf', 'Pre-colonial Davao trade among Indigenous communities and maritime traders.', 'Rivers, coast, forest, settlements', ['Floating driftwood', 'River currents', 'Falling durian', 'Mangrove roots', 'Broken bamboo bridges', 'Trading boats', 'Muddy banks', 'Thorny vines'], 'Rising Tide: water gradually rises.', TEAL),
    (2, 'New Flags, New Rules', 'Spanish expedition of 1848 and resistance associated with Datu Bago.', 'Riverside settlements and Davao Gulf', ['Rolling cannonballs', 'Cannon fire', 'Wooden barricades', 'Falling fort debris', 'Spike barricades', 'Guard patrols', 'Crumbling watchtowers', 'Moving-boat crossing'], 'Cannon Barrage: alternating fire patterns.', GOLD),
    (3, 'Abaca Boom, City Bloom', 'Abaca plantations, Japanese migration, and Mintal as Little Tokyo.', 'Plantations and processing facilities', ['Abaca bundles', 'Rolling carts', 'Falling crates', 'Tangled fibers', 'Irrigation ditches', 'Farm machinery', 'Unstable walkways', 'Muddy paths'], 'Timed platforms and moving machinery.', CORAL),
]
for n, title, hist, setting, obs, special, col in level_data:
    left = Table([[stage_image(n, 52*mm, 29*mm)], [P(f'<b>LEVEL {n}</b> | {title}', 'CardTitle')], [P(hist, 'Smallx')]], colWidths=[57*mm])
    left.setStyle(TableStyle([('BACKGROUND',(0,0),(-1,-1),WHITE),('BOX',(0,0),(-1,-1),0.7,HexColor('#D6D0C4')),('LINEBEFORE',(0,0),(0,-1),4,col),('LEFTPADDING',(0,0),(-1,-1),6),('RIGHTPADDING',(0,0),(-1,-1),6),('TOPPADDING',(0,0),(-1,-1),5),('BOTTOMPADDING',(0,0),(-1,-1),5)]))
    right = Table([[P('<b>SETTING</b><br/>'+setting, 'CardText')], [P('<b>HAZARD KIT</b><br/>'+bullets(obs), 'CardText')], [P('<b>SIGNATURE BEAT</b><br/>'+special, 'CardText')]], colWidths=[112*mm])
    right.setStyle(TableStyle([('BACKGROUND',(0,0),(-1,-1),WHITE),('BOX',(0,0),(-1,-1),0.7,HexColor('#D6D0C4')),('LEFTPADDING',(0,0),(-1,-1),8),('RIGHTPADDING',(0,0),(-1,-1),8),('TOPPADDING',(0,0),(-1,-1),5),('BOTTOMPADDING',(0,0),(-1,-1),5)]))
    story.append(Table([[left, right]], colWidths=[63*mm, 118*mm], style=TableStyle([('VALIGN',(0,0),(-1,-1),'TOP'),('LEFTPADDING',(0,0),(-1,-1),0),('RIGHTPADDING',(0,0),(-1,-1),5)])))
    story.append(Spacer(1, 4*mm))
story.append(P('Level 1-3 authoring pass: place a safe tutorial stretch, a collectible route, a first enemy teaching beat, a difficulty ramp, and a boss arena that showcases the signature mechanic.', 'Smallx'))
story.append(Spacer(1, 7*mm))
story.append(P('Level 3 deep-dive checklist', 'H2x'))
story.append(Table([[card('TEACH', 'Introduce abaca bundles and muddy paths in a low-pressure opening stretch.', LIGHT_TEAL, 55*mm, TEAL), card('ESCALATE', 'Add rolling carts, irrigation gaps, then timed machinery as the player advances.', LIGHT_CORAL, 55*mm, CORAL), card('REWARD', 'Place cacao and a power-up route around the risky platform line so mastery is optional but valuable.', LIGHT_GOLD, 55*mm, GOLD), card('DECIDE', 'Confirm how Japanese enemy encounters connect to the plantation setting and the Level 3 boss beat.', LIGHT_BLUE, 55*mm, BLUE)]], colWidths=[60*mm]*4, style=TableStyle([('VALIGN',(0,0),(-1,-1),'TOP'),('LEFTPADDING',(0,0),(-1,-1),0),('RIGHTPADDING',(0,0),(-1,-1),4)])))
story.append(PageBreak())

story.append(P('05 | LEVELS 4-5: PRESSURE AND PAYOFF', 'H1x'))
story.append(P('The final two levels combine the earlier vocabulary. Avoid introducing every hazard at once: use distinct sub-sections so players can read the challenge and recover between beats.', 'Bodyx'))
for n, title, hist, setting, obs, special, col in [
    (4, 'Davao Under Fire', 'Japanese invasion, the Davao Dozen escape, and liberation campaigns.', 'Wartime Davao: jungle routes, damaged roads, occupied areas.', ['Barbed wire', 'Falling debris', 'Exploding shells', 'Spotlights', 'Landmines', 'Collapsed bridges', 'Roadblocks', 'Patrol soldiers', 'Smoke clouds', 'Crumbling trenches'], 'Escape / survival sequence with stealth, projectiles, and environmental hazards.', BLUE),
    (5, 'Old Roots, New Routes', 'Changing provinces, Indigenous and Moro communities, festivals, crafts, agriculture, and modern growth.', 'Modern Davao City: urban development, markets, agriculture, transport.', ['Moving jeepneys', 'Construction barriers', 'Falling durian', 'Fruit carts', 'Flooded streets', 'Drainage canals', 'Hanging wires', 'Construction debris', 'Market crates', 'Busy intersections'], 'City Rush: fast combined section with jeepneys, barriers, and market carts.', GREEN),
]:
    left = Table([[stage_image(n, 68*mm, 38*mm)], [P(f'<b>LEVEL {n}</b> | {title}', 'CardTitle')], [P(hist, 'Smallx')]], colWidths=[74*mm])
    left.setStyle(TableStyle([('BACKGROUND',(0,0),(-1,-1),WHITE),('BOX',(0,0),(-1,-1),0.7,HexColor('#D6D0C4')),('LINEBEFORE',(0,0),(0,-1),4,col),('LEFTPADDING',(0,0),(-1,-1),7),('RIGHTPADDING',(0,0),(-1,-1),7),('TOPPADDING',(0,0),(-1,-1),6),('BOTTOMPADDING',(0,0),(-1,-1),6)]))
    right = Table([[P('<b>SETTING</b><br/>'+setting, 'CardText')], [P('<b>HAZARD KIT</b><br/>'+bullets(obs), 'CardText')], [P('<b>SIGNATURE MISSION</b><br/>'+special, 'CardText')]], colWidths=[111*mm])
    right.setStyle(TableStyle([('BACKGROUND',(0,0),(-1,-1),WHITE),('BOX',(0,0),(-1,-1),0.7,HexColor('#D6D0C4')),('LEFTPADDING',(0,0),(-1,-1),9),('RIGHTPADDING',(0,0),(-1,-1),9),('TOPPADDING',(0,0),(-1,-1),7),('BOTTOMPADDING',(0,0),(-1,-1),7)]))
    story.append(Table([[left, right]], colWidths=[84*mm, 118*mm], style=TableStyle([('VALIGN',(0,0),(-1,-1),'TOP'),('LEFTPADDING',(0,0),(-1,-1),0),('RIGHTPADDING',(0,0),(-1,-1),7)])))
    story.append(Spacer(1, 5*mm))
story.append(PageBreak())

# Enemies
story.append(P('06 | ENEMIES AND BOSS ENCOUNTERS', 'H1x'))
story.append(P('Enemy design is the combat curriculum: teach a readable attack at range, a readable close-range threat, and a way for the chosen character or power-up to answer it.', 'Bodyx'))
enemy_rows = [
    [P('<font color="#FFFFFF">ENEMY</font>', 'CardTitle'), P('<font color="#FFFFFF">APPEARS</font>', 'CardTitle'), P('<font color="#FFFFFF">HEALTH / ATTACK</font>', 'CardTitle'), P('<font color="#FFFFFF">PLAYER COUNTER</font>', 'CardTitle')],
    [P('<b>Rotten Cacao</b>', 'CardText'), P('Levels 1-5', 'CardText'), P('3 hearts. Poison removes 1 player heart every 10 seconds.', 'CardText'), P('Defeat before the next poison tick. Use attack-speed cacao and damage buffs.', 'CardText')],
    [P('<b>Evil Durian</b>', 'CardText'), P('Levels 1-5', 'CardText'), P('3 hearts. Spike attack removes 1 heart and knocks player backward.', 'CardText'), P('Maintain spacing; use thrown durian, basket, snare, or reflected damage.', 'CardText')],
    [P('<b>Spanish Soldier / Friar</b>', 'CardText'), P('Level 2', 'CardText'), P('Friar obscures vision for 3s, disappears for 1s.', 'CardText'), P('Telegraph the blind window and keep the arena readable at the edges.', 'CardText')],
    [P('<b>Japanese Soldier</b>', 'CardText'), P('Levels 3-4', 'CardText'), P('Long range: sushi projectiles in a 3s attack, repeats every 2s. Close range: wooden stick.', 'CardText'), P('Force distance choice: dodge projectiles or close in before the next volley.', 'CardText')],
    [P('<b>American Soldier</b>', 'CardText'), P('Level 4', 'CardText'), P('Long range: books in a 3s attack, repeats every 2s. Close range: punch.', 'CardText'), P('Use cover / movement rhythm; decide whether books are parryable or dodge-only.', 'CardText')],
]
et = Table(enemy_rows, colWidths=[48*mm, 29*mm, 91*mm, 79*mm])
et.setStyle(TableStyle([('BACKGROUND',(0,0),(-1,0),INK),('TEXTCOLOR',(0,0),(-1,0),WHITE),('GRID',(0,0),(-1,-1),0.5,HexColor('#D6D0C4')),('VALIGN',(0,0),(-1,-1),'TOP'),('LEFTPADDING',(0,0),(-1,-1),7),('RIGHTPADDING',(0,0),(-1,-1),7),('TOPPADDING',(0,0),(-1,-1),6),('BACKGROUND',(0,1),(-1,-1),WHITE)]))
story.append(et)
story.append(Spacer(1, 7*mm))
story.append(P('Boss encounter checklist', 'H2x'))
story.append(Table([[card('ARENA', 'A readable space with a safe reset point, clear edges, and room for the player\'s chosen weapon.', LIGHT_TEAL, 57*mm, TEAL), card('PHASES', 'At least two escalating patterns, with a short recovery or telegraph between them.', LIGHT_CORAL, 57*mm, CORAL), card('REWARD', 'Boss defeat must feed the level result: stars, score, story closure, or a Davao element.', LIGHT_GOLD, 57*mm, GOLD), card('FAILURE', 'Damage, knockback, and status effects must be recoverable and readable before the next hit.', LIGHT_BLUE, 57*mm, BLUE)]], colWidths=[62*mm]*4, style=TableStyle([('VALIGN',(0,0),(-1,-1),'TOP'),('LEFTPADDING',(0,0),(-1,-1),0),('RIGHTPADDING',(0,0),(-1,-1),4)])))
story.append(PageBreak())

# Missing / production checklist
story.append(P('07 | MISSING PIECES TO LOCK', 'H1x'))
story.append(P('These are the decisions the planning docs imply but do not fully specify. Locking them early will prevent rework across level scenes, UI, and balance.', 'Bodyx'))
items = [
    ('PLAYER CONTROL', 'Final movement speed, jump height, attack input, damage invulnerability window, fall recovery, and whether midair attacks are allowed.'),
    ('CHARACTER SELECT', 'How many playable characters ship? Can every character play every level? How are costume colors selected and previewed?'),
    ('WEAPON RULES', 'Starting inventory, pickup limits, attack range, ammo / charges, and whether weapons persist between levels.'),
    ('BOSS PLAN', 'Name and behavior for each level boss. The docs list enemies but do not define five distinct boss encounters.'),
    ('HISTORICAL UI', 'Exact dates, intro copy, story labels, glossary / fact cards, and a respectful framing for conflict-era content.'),
    ('LEVEL FLOW', 'Start menu -> character select -> level intro -> run -> boss -> results -> replay / next level. Define unlock rules.'),
    ('AUDIO + FEEDBACK', 'Music loop per era, pickup sounds, hit / death cues, boss cue, and accessibility options for flashes / screen obscuring.'),
    ('QA TARGETS', 'Minimum FPS / resolution, controller support, playtest rubric, difficulty pass, and a final three-week release checklist.'),
]
grid = []
for i in range(0, len(items), 2):
    grid.append([card(items[i][0], items[i][1], WHITE, 86*mm, [TEAL,GOLD,CORAL,BLUE][i//2 % 4]), card(items[i+1][0], items[i+1][1], WHITE, 86*mm, [GOLD,CORAL,BLUE,TEAL][i//2 % 4])])
story.append(Table(grid, colWidths=[91*mm,91*mm], style=TableStyle([('VALIGN',(0,0),(-1,-1),'TOP'),('LEFTPADDING',(0,0),(-1,-1),0),('RIGHTPADDING',(0,0),(-1,-1),6),('TOPPADDING',(0,0),(-1,-1),3),('BOTTOMPADDING',(0,0),(-1,-1),3)])))
story.append(Spacer(1, 6*mm))
story.append(P('Suggested implementation order', 'H2x'))
story.append(P('<b>1.</b> Lock player movement, health, combat, and one enemy.  <b>2.</b> Finish one vertical-slice level with intro, HUD, collectibles, boss, and end screen.  <b>3.</b> Reuse the slice for levels 2-5, swapping hazards, art, enemy behaviors, and story labels.  <b>4.</b> Add character buffs and power-up balance.  <b>5.</b> Run alpha / beta testing and polish feedback, audio, and accessibility.', 'Bodyx'))
story.append(Spacer(1, 8*mm))
story.append(P('Sources used', 'H2x'))
story.append(P('Project planning docs: doc/plan_game_concept.md, doc/plan_characters.md, doc/plan_level_progression.md. Existing project signals were cross-checked against the Godot scenes, scripts, and asset folders in this repository.', 'Smallx'))

doc = SimpleDocTemplate(OUT, pagesize=landscape(A4), rightMargin=15*mm, leftMargin=15*mm, topMargin=13*mm, bottomMargin=15*mm, title='Davao Chronicles Game Plan', author='Codex')
doc.build(story, onFirstPage=footer, onLaterPages=footer)
print(OUT)
