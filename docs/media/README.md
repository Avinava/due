# Recording the README clip

The README clip is a 15-second loop: drag the dial to the 15th, tap School fees, watch the total count down, then Undo.

1. Boot an iPhone simulator and run the app on it: `cd app && flutter run -d <simulator>`.
2. In Settings, tap Reset to sample household, so the numbers match the README.
3. Record: `xcrun simctl io booted recordVideo --codec h264 docs/media/due.mov`. Do the loop, then press Ctrl-C.
4. Make the MP4 and GIF:

   ```sh
   ffmpeg -i docs/media/due.mov -vf "fps=30,scale=780:-2" -c:v libx264 -crf 24 -an docs/media/due.mp4
   ffmpeg -i docs/media/due.mov -vf "fps=15,scale=390:-1:flags=lanczos,split[a][b];[a]palettegen[p];[b][p]paletteuse" docs/media/due.gif
   ```

5. Delete `due.mov` and commit the MP4 and GIF.
