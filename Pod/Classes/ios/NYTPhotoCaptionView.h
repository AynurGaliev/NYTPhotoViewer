//
//  NYTPhotoCaptionView.h
//  NYTPhotoViewer
//
//  Created by Brian Capps on 2/18/15.
//
//

@import UIKit;

NS_ASSUME_NONNULL_BEGIN

/**
 *  A view used to display the caption for a photo.
 */
@interface NYTPhotoCaptionView : UIView 

/**
 *  Designated initializer that takes all the caption attributed strings as arguments.
 *
 *  @param attributedTitle   The attributed string used as the title. The top string in the caption view.
 *  @param attributedSummary The attributed string used as the summary. The second from the top string in the caption view.
 *  @param attributedCredit  The attributed string used as the credit. The third from the top string in the caption view.
 *
 *  @return A fully initialized object.
 */
- (instancetype)initWithTitle:(nullable NSString*) title  NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
