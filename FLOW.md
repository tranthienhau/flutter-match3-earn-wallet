# Screenshot capture flow

The README screenshots are real captures from the app running on an iOS
simulator, produced by the `integration_test` harness (not mockups).

## How the harness works

- `test_driver/integration_test.dart` is the driver. It uses
  `integrationDriver(onScreenshot:)` to write each PNG that the test emits into
  the `screenshots/` folder, keyed by the name passed to `takeScreenshot`.
- `integration_test/screenshot_test.dart` is the test target. It pumps the real
  `Match3EarnApp`, drives the five key screens (game board, win + level reward,
  wallet, OPay payout, earn/offerwall) plus the device-integrity panel, and at
  each stop calls:
  - `binding.convertFlutterSurfaceToImage()` to rasterize the Flutter surface,
  - `binding.takeScreenshot('NN-name')` to hand the bytes to the driver.
- The memory-match board uses a fixed RNG seed (42), so the matching card index
  pairs are deterministic and the gameplay screenshots are reproducible.

## Steps

1. Boot the simulator (ignore the error if it is already booted):

   ```bash
   xcrun simctl boot "iPhone 17 Pro"
   ```

2. Fetch packages:

   ```bash
   flutter pub get
   ```

3. Run the capture (writes PNGs to `screenshots/`):

   ```bash
   flutter drive \
     --driver test_driver/integration_test.dart \
     --target integration_test/screenshot_test.dart \
     -d "iPhone 17 Pro"
   ```

## Extra media

- `screenshots/demo.gif` - a slideshow built from the captured PNGs with ffmpeg:

  ```bash
  cd screenshots
  ffmpeg -y -framerate 1 -pattern_type glob -i '0*.png' \
    -vf "fps=1,scale=320:-1:flags=lanczos,split[s0][s1];[s0]palettegen[p];[s1][p]paletteuse" \
    demo.gif
  ```

- `screenshots/flow-diagram.png` - rendered from `flow.mmd` with Mermaid CLI:

  ```bash
  mmdc -i flow.mmd -o screenshots/flow-diagram.png -b white -w 1400
  ```
