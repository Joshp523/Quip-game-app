# QuipRash

A customizable, comic-book party game in the spirit of Quiplash. Write your own prompts, answer on your phones, vote on the funniest, and watch the podium at the end. Runs entirely in the browser on **GitHub Pages** with a free **Supabase** database for realtime sync. No build step.

## How it plays

1. The host opens the site on a laptop or TV and clicks **Create room**.
2. Players open the same URL on their phones, enter the 4-letter code and a name, and (optionally) add a photo. No photo means a random face.
3. Prompts live in a shared library that is saved permanently and reused every game. In the lobby, players can add their own from their phones. The host sees those redacted until they click **Reveal custom prompts**, and can delete any prompt, including the starter ones.
4. Each round, players write answers to their prompts, then everyone votes on the matchups.
5. Round 2 is worth ×2 points and round 3 is worth ×3.
6. Ties for first place trigger a sudden-death round where everybody plays and the winner takes all.
7. The game ends with a podium, and the host can play again with the same players.

**Two players?** Head-to-head mode switches on automatically. You both answer every prompt, then rate each other's answers from 1 to 5.

The game runs itself: timers advance each phase, and the host can pause, add 15 seconds, or skip at any point.

## Setup

1. **Create a Supabase project** (free tier is fine).
2. In the Supabase **SQL Editor**, run `schema.sql`. It's safe to re-run.
3. Open `index.html` and set your values near the top of the script:
   ```js
   const SUPABASE_URL = "https://YOUR-PROJECT.supabase.co";
   const SUPABASE_KEY = "YOUR-ANON-OR-PUBLISHABLE-KEY";
   ```
4. Push everything to a GitHub repo and enable **Settings → Pages** (deploy from the main branch, root folder).
5. Open the Pages URL and create a room.

### Files for the repo root

| File | Purpose |
|---|---|
| `index.html` | The whole game (HTML, CSS, JS) |
| `schema.sql` | Database tables, realtime, and access policies |
| `favicon.ico`, `favicon-16x16.png`, `favicon-32x32.png` | Browser tab icons |
| `apple-touch-icon.png`, `android-chrome-*.png`, `site.webmanifest` | Home-screen icons |

## Game settings

Click **Game settings** at the bottom of the lobby to change:

- Answer, vote, results and scoreboard timers (0 = no timer)
- Number of rounds and matchups per round
- Points per vote, sweep bonus, and max answer length
- Duel mode (two players per prompt) or free-for-all (everyone answers)
- Auto-advance and auto-start timers, and prompt shuffling
- **Background music:** the built-in carnival tune, or your own MP3, M4A, WAV or OGG file (max 25 MB). Your track is stored only in the host's browser and loops automatically. Music starts on the host's first click.

## Notes

- **Security:** there are no accounts. The tables allow anyone with your public key to read and write, which is fine for a game among friends but not for anything private.
- **Cleanup:** rooms never expire. Use **End room** in the game, or run this now and then:
  ```sql
  delete from qp_rooms where created_at < now() - interval '7 days';
  ```
- **Players:** the minimum is 2 and there's no maximum. Matchups per round scale with the number of players (one per player by default).
- **Troubleshooting:** if "Create room" fails, check the key and URL, and make sure `schema.sql` ran without errors in the same project your keys point to. If photos fail with a "check constraint" or "too long" error, re-run `schema.sql`, which removes old photo size limits. If they fail with a "schema cache" error, run `notify pgrst, 'reload schema';` in the SQL Editor and try again.
