# Calendar Progress Bar — Plan & Implementation Notes

A thin always-on-top horizontal line at the bottom of the macOS screen that
fills left-to-right as time elapses against the current calendar event (or a
manually-triggered timer). Visual ancestor: the Reveal.js progress bar that
the Obsidian Advanced Slides plugin shows during a slideshow.

---

## 1. Goal

Make "how much time is left in this thing I'm doing" *peripherally visible*
without requiring a glance at a clock and a subtraction. The brain reads a
filling bar faster than it reads `14:23 / 30:00`, and an always-on overlay
removes the "remember to check" step.

## 2. Alternatives considered, and why they were dropped

| Candidate                 | Reason dropped                                                                 |
|---------------------------|--------------------------------------------------------------------------------|
| tmux status bar           | One character row tall; competes with existing status content; only visible inside tmux. Wrong shape for a full-screen ambient cue. |
| Übersicht widget          | Sits *behind* application windows by default. Fighting that defeats the purpose. |
| SwiftBar / xbar menu bar  | Wrong primitive — menu bar is a strip of icons, not a line you can fill.       |
| Native SwiftUI app        | Correct, polished, but two evenings of entitlements and signing for a 3 px line. |
| Electron overlay          | Heavy runtime cost for a trivial visual.                                       |

**Choice: Hammerspoon.** `hs.canvas` draws a borderless, click-through,
always-on-top, ignores-Spaces overlay in ~30 lines of Lua. No code signing,
no App Store, no Xcode.

## 3. Architecture

```
┌────────────────────────────────────────────────────────────┐
│                    user space                              │
│                                                            │
│   ⌃⌥⌘T ─►  hs.dialog ─►  manualTimer state                 │
│                                  │                         │
│   icalBuddy ─►  refreshEvent ─►  currentEvent state        │
│   (every 60s)                    │                         │
│                                  ▼                         │
│                          activeSource()                    │
│                          (manual wins if both)             │
│                                  │                         │
│                                  ▼                         │
│   hs.timer (1s) ─►  tick() ─►  hs.canvas frame update      │
│                                                            │
└────────────────────────────────────────────────────────────┘
```

Two independent loops, decoupled cadences:

- **Calendar refresh loop** — runs `icalBuddy eventsNow` every 60 s.
  Polling, not push, because there is no event-bus from Calendar.app worth
  the integration cost.
- **Render loop** — `tick()` runs every 1 s. It picks an active source,
  computes `elapsed / total`, and sets the filled rectangle's width as a
  percentage string. Cheap; no calendar calls in the render path.

Source priority: **manual timer overrides calendar event** when both are
active. Rationale: the user invoking the hotkey is a fresher act of
intention than whatever was scheduled.

## 4. Calendar integration: `icalBuddy`

Reads directly from the macOS Calendar database. No OAuth, no API keys —
just one Calendar permission prompt the first time. Anything that already
syncs into Calendar.app (Google, Exchange, iCloud, CalDAV) becomes
queryable for free.

```bash
icalBuddy -nc -b "" \
  -iep 'datetime,title' \
  -eep 'notes,url,location,attendees' \
  -df "%Y-%m-%d" -tf "%H:%M:%S" \
  -po 'datetime,title' \
  eventsNow
```

Output format varies by icalBuddy version and system locale. The parser
in the script handles the most common shape; the regex is the part most
likely to need adjustment per machine.

**Filter:** events longer than `MAX_EVENT_HOURS` (default 20) are
discarded. This silently kills the obvious problem of an all-day "Office
Hours" block making the bar tick forward by 0.07 % per minute.

## 5. Manual timer mode

Hotkeys:

- `⌃⌥⌘T` → text prompt → start
- `⌃⌥⌘.` → cancel running timer

Input parser accepts:

| Input          | Meaning            |
|----------------|--------------------|
| `25`           | 25 minutes         |
| `25 deep work` | 25 minutes, label "deep work" |
| `1h30`         | 90 minutes         |
| `1:30`         | 90 minutes         |
| `90s`          | 1.5 minutes        |

On completion: system notification + the bar fades to invisible, then
falls back to whatever calendar event is current (if any).

**Visual distinction:** manual timer renders in a blue palette,
calendar event renders in a green palette. Both escalate through amber
→ red as they near completion. At a glance, you can tell which source
is driving the bar.

## 6. Failure modes and what we did about each

| Failure mode                              | Mitigation                                                                 |
|-------------------------------------------|----------------------------------------------------------------------------|
| All-day / very long events flood the bar  | Discard events longer than `MAX_EVENT_HOURS` (20)                          |
| Multi-display setup                       | Currently primary display only. To extend, loop `hs.screen.allScreens()`   |
| Notebook notch                            | `frame()` already excludes menu bar area; bar placed below it              |
| Native fullscreen apps                    | OS-level limitation; overlay can't appear over true exclusive fullscreen   |
| Overlapping events                        | Parser picks first event icalBuddy lists. Decide a real rule before this bites you. |
| Calendar permission denied                | icalBuddy returns empty; bar simply stays invisible                        |
| Hammerspoon timer GC                      | **Critical.** Timer and watcher handles MUST be held at module scope or Lua GC collects them mid-session and the bar silently freezes. Causes the "worked fine then stopped halfway" symptom. |
| Runtime error inside `tick()`             | Wrap in `pcall`, log to `hs.console`. Otherwise an exception can kill the timer loop. |
| icalBuddy output format drift             | Parser regex is the first thing to touch when the bar stops reflecting reality |
| Locale decimal separator in percentages   | Theoretical concern in `es-CL`-style locales. `tostring(50.5)` in standard Lua is locale-independent; unlikely to bite, but the fallback is `string.format("%.2f", pct*100)`. |

## 7. Open assumptions worth re-examining at the 30-day mark

These are the design bets that will look right or wrong only with usage,
not analysis:

1. **Calendar reflects reality.** This whole thing is useful in proportion
   to how religiously the user time-blocks. If 80 % of focused work
   happens *between* scheduled meetings, the bar will be empty during the
   work that most benefits from a timer, and full during meetings (where
   the visual nudge matters less). Manual mode partially compensates,
   but only if the user remembers to trigger it.
2. **Peripheral motion is helpful, not anxiogenic.** Same data, opposite
   nervous-system response across users. If after a week the bar is more
   stressor than aid, the fix isn't tuning — it's switching to
   on-demand-only mode (manual hotkey, no calendar polling).
3. **The bottom edge is the right placement.** Top-of-screen places the
   bar adjacent to the menu bar (busy area). Bottom places it adjacent to
   the Dock (also busy if Dock is shown). On a notched MacBook with
   auto-hide Dock, bottom is cleanest. On an external monitor without a
   Dock, both work.
4. **1 s tick is the right cadence.** Faster is wasteful for a bar that
   moves 0.07 % per second on a 30-min event. Slower starts to feel laggy
   on short timers. 1 s is the well-trodden default.
5. **Manual overrides calendar, not the other way around.** Tested
   intuitively; if it turns out the user starts manual timers *during*
   meetings and wants the meeting bar instead, flip the precedence in
   `activeSource()`.

## 8. Future extensions (only if real usage demands them)

These are explicitly *not* in v1 because each adds bug surface that needs
to be justified by real friction, not anticipated friction:

- **Pause / resume.** Adds state bugs around sleep, expiry-while-paused,
  multiple-pauses. Default discipline: if interrupted, restart.
- **Per-display bars.** One canvas per screen. ~10 extra lines but
  doubles the surface area for screen-watcher edge cases.
- **Custom palettes per calendar.** Show e.g. blue for "Focus" calendar,
  red for "Meetings" calendar. Requires reading the source calendar from
  icalBuddy and a config map.
- **End-of-event "5 min remaining" pulse.** A short animation when
  `pct > 0.83`. Easy. Adds urgency cue without adding text.
- **History log.** Append every completed timer to a markdown file.
  Useful for review; trivial to add; deferred until requested.

## 9. Installation summary

```bash
brew install hammerspoon ical-buddy
```

1. Drop the script into `~/.hammerspoon/init.lua`.
2. Adjust `ICALBUDDY_PATH` if not on Apple Silicon.
3. Run the icalBuddy command above once from Terminal to verify output
   format and trigger the Calendar permission prompt.
4. Launch Hammerspoon, grant Accessibility permission.
5. Menu icon → Reload Config.
6. Test with `⌃⌥⌘T` → `1` (a 1-minute timer) to confirm the bar fills
   end-to-end and the completion notification fires.

If anything misbehaves: Hammerspoon menu → Console, reload, watch for
errors. The Console is the only place runtime errors surface; everything
else is silent.
