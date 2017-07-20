# CCVideoRangeSlider
A full-custom video range slider for trimming videos written in Swift 4

![Image of Slider](https://cdn.pbrd.co/images/GBMtz0W.png)

## How to use it?

- Create an UIView with storyboard and assign CCVideoRangeSlider class
- Link the IBOutlet to your view controller
- Extend your view controller with CCVideoRangeSliderDelegate

Then use it like this:

```swift
class ViewController: UIViewController, CCVideoRangeSliderDelegate {

  @IBOutlet weak var videoRangeSlider: CCVideoRangeSlider!
  override func viewDidLoad() {
      super.viewDidLoad()

      videoRangeSlider.delegate = self
      videoRangeSlider.initSlider(startTime: 0.0, endTime: 9.0)
  }
  ...
}
```

## Coming soon:

- Change both range and indicators colors
