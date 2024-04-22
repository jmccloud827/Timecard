import AppTrackingTransparency
import GoogleMobileAds
import SwiftUI
import Combine

struct BannerView: View {
    @State private var adDidLoad = false
    @AppStorage("6C5006E9622B492DA829C274F89C8EF4") private var disableAds = false
    static let adDidLoad = PassthroughSubject<Bool, Never>()
    
    private var size: CGSize {
        GADCurrentOrientationAnchoredAdaptiveBannerAdSizeWithWidth(UIScreen.main.bounds.width).size
    }
    
    var body: some View {
        if !disableAds {
            BannerUiKitView()
                .frame(width: adDidLoad ? size.width : 0, height: adDidLoad ? size.height : 0)
                .onReceive(Self.adDidLoad) { value in
                    adDidLoad = value
                }
        }
    }
    
    private struct BannerUiKitView: UIViewControllerRepresentable {
        func makeUIViewController(context _: Context) -> ViewController {
            ViewController()
        }
        
        func updateUIViewController(_: ViewController, context _: Context) {}
        
        class ViewController: UIViewController, GADBannerViewDelegate {
            var bannerView = GADBannerView(adSize: GADCurrentOrientationAnchoredAdaptiveBannerAdSizeWithWidth(UIScreen.main.bounds.width))
            
            override func viewDidLoad() {
                super.viewDidLoad()
                #if DEBUG
                    bannerView.adUnitID = "ca-app-pub-3940256099942544/2934735716"
                #else
                    bannerView.adUnitID = "ca-app-pub-7876954544180802/6210244928"
                #endif
                bannerView.rootViewController = self
                bannerView.delegate = self
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    ATTrackingManager.requestTrackingAuthorization { status in
                        if status != .notDetermined && status != .restricted {
                            GADMobileAds.sharedInstance().start(completionHandler: nil)
                            self.bannerView.load(GADRequest())
                        }
                    }
                }
            }
            
            func addBannerViewToView(_ bannerView: GADBannerView) {
                bannerView.translatesAutoresizingMaskIntoConstraints = false
                view.addSubview(bannerView)
                view.addConstraints(
                    [
                        NSLayoutConstraint(item: bannerView,
                                           attribute: .bottom,
                                           relatedBy: .equal,
                                           toItem: view.safeAreaLayoutGuide,
                                           attribute: .bottom,
                                           multiplier: 1,
                                           constant: 0),
                        NSLayoutConstraint(item: bannerView,
                                           attribute: .centerX,
                                           relatedBy: .equal,
                                           toItem: view,
                                           attribute: .centerX,
                                           multiplier: 1,
                                           constant: 0)
                    ])
            }
            
            func bannerViewDidReceiveAd(_ bannerView: GADBannerView) {
                print("bannerViewDidReceiveAd")
                addBannerViewToView(bannerView)
                BannerView.adDidLoad.send(true)
                bannerView.alpha = 0
                UIView.animate(withDuration: 1) {
                    bannerView.alpha = 1
                }
            }
            
            func bannerView(_: GADBannerView, didFailToReceiveAdWithError error: Error) {
                print("bannerView:didFailToReceiveAdWithError: \(error.localizedDescription)")
            }
            
            func bannerViewDidRecordImpression(_: GADBannerView) {
                print("bannerViewDidRecordImpression")
            }
            
            func bannerViewWillPresentScreen(_: GADBannerView) {
                print("bannerViewWillPresentScreen")
            }
            
            func bannerViewWillDismissScreen(_: GADBannerView) {
                print("bannerViewWillDismissScreen")
            }
            
            func bannerViewDidDismissScreen(_: GADBannerView) {
                print("bannerViewDidDismissScreen")
            }
        }
    }
}
