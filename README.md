## On the Map

### *Tech Used*
* Xcode 9
* Swift 4
* iOS 9.3+
* REST API

Frameworks:  
- Foundation  
- UIKit  
- MapKit  

### *Description*

*On the Map* allows a user to login via Udacity to view and place pins with informational links.


### *Interesting Twists*

I was curious how to create a view that would work in conjunction with Interface Builder (IB). As part of On the Map, I needed to display a gradient-color background. After researching, I decided to make a specialty view that integrated with IB to handle this background. **LoginView.swift** is the result.

The `gradientColor` variable is decorated with `@IBInspectable` and is property observing-compliant (note the `didSet`). This causes IB to display this variable in the Attributes Inspector. To see it in action:

- Click on the view in Interface Builder.
- At the top of the Attribute Inspector, use the dropdown to choose a Login View color.
- The chosen color becomes the center of a 3-tone gradient, determined in the view's code.

The class itself is decorated with `@IBDesignable`. This tells IB to display the view directly in the canvas. You can then edit the view directly as you would a normal UIView - with the color gradient displayed in the view as you work.

This is a cool way to make your own fully customized view, allowing developers to adjust properties as they would with any other UIKit framework view.


### *Setup Requirements*

Requires a Udacity login:

[Signup Page](https://auth.udacity.com/sign-up?_ga=1.261743181.1763484505.1459126598&next=https%3A%2F%2Fclassroom.udacity.com%2Fauthenticated)

[Sitemap link to a list of Udacity's Free Courses](https://www.udacity.com/sitemap)

Once you have a login, you'll be able to place yourself *On the Map*, as well as seeing what others have posted.

### *Other Notes*

- Although, I added a sign up link and a Facebook login to the initial view, those features are not implemented in this version of the code.
- Updated for Swift 4. Runs successfully, but gives various warnings about insets and annotation layer issues.



