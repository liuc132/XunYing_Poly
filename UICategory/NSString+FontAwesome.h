//
//  NSString+FontAwesome.h
//
//  FontAwesome特殊字符集，
//
//  1.需要在info.plist
//  Fonts provided by application 加入FontAwesome.ttf
//
//  2.需要在resoures里面，增加资源文件FontAwesome.ttf
//
//  Created by 周杨 on 15/1/7.
//  Copyright (c) 2015年 zhouy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CommonCrypto/CommonDigest.h>

@interface NSString (FontAwesome)
typedef enum {
    FAIconGlass = 0,
    FAIconMusic,
    FAIconSearch,
    FAIconEnvelope,
    FAIconHeart,
    FAIconStar,
    FAIconStarEmpty,
    FAIconUser,
    FAIconFilm,
    FAIconThLarge,
    FAIconTh,
    FAIconThList,
    FAIconOk,
    FAIconRemove,
    FAIconZoomIn,
    FAIconZoomOut,
    FAIconOff,
    FAIconSignal,
    FAIconCog,
    FAIconTrash,
    FAIconHome,
    FAIconFile,
    FAIconTime,
    FAIconRoad,
    FAIconDownloadAlt,
    FAIconDownload,
    FAIconUpload,
    FAIconInbox,
    FAIconPlayCircle,
    FAIconRepeat,
    FAIconRefresh,
    FAIconListAlt,
    FAIconLock,
    FAIconFlag,
    FAIconHeadphones,
    FAIconVolumeOff,
    FAIconVolumeDown,
    FAIconVolumeUp,
    FAIconQrcode,
    FAIconBarcode,
    FAIconTag,
    FAIconTags,
    FAIconBook,
    FAIconBookmark,
    FAIconPrint,
    FAIconCamera,
    FAIconFont,
    FAIconBold,
    FAIconItalic,
    FAIconTextHeight,
    FAIconTextWidth,
    FAIconAlignLeft,
    FAIconAlignCenter,
    FAIconAlignRight,
    FAIconAlignJustify,
    FAIconList,
    FAIconIndentLeft,
    FAIconIndentRight,
    FAIconFacetimeVideo,
    FAIconPicture,
    FAIconPencil,
    FAIconMapMarker,
    FAIconAdjust,
    FAIconTint,
    FAIconEdit,
    FAIconShare,
    FAIconCheck,
    FAIconMove,
    FAIconStepBackward,
    FAIconFastBackward,
    FAIconBackward,
    FAIconPlay,
    FAIconPause,
    FAIconStop,
    FAIconForward,
    FAIconFastForward,
    FAIconStepForward,
    FAIconEject,
    FAIconChevronLeft,
    FAIconChevronRight,
    FAIconPlusSign,
    FAIconMinusSign,
    FAIconRemoveSign,
    FAIconOkSign,
    FAIconQuestionSign,
    FAIconInfoSign,
    FAIconScreenshot,
    FAIconRemoveCircle,
    FAIconOkCircle,
    FAIconBanCircle,
    FAIconArrowLeft,
    FAIconArrowRight,
    FAIconArrowUp,
    FAIconArrowDown,
    FAIconShareAlt,
    FAIconResizeFull,
    FAIconResizeSmall,
    FAIconPlus,
    FAIconMinus,
    FAIconAsterisk,
    FAIconExclamationSign,
    FAIconGift,
    FAIconLeaf,
    FAIconFire,
    FAIconEyeOpen,
    FAIconEyeClose,
    FAIconWarningSign,
    FAIconPlane,
    FAIconCalendar,
    FAIconRandom,
    FAIconComment,
    FAIconMagnet,
    FAIconChevronUp,
    FAIconChevronDown,
    FAIconRetweet,
    FAIconShoppingCart,
    FAIconFolderClose,
    FAIconFolderOpen,
    FAIconResizeVertical,
    FAIconResizeHorizontal,
    FAIconBarChart,
    FAIconTwitterSign,
    FAIconFacebookSign,
    FAIconCameraRetro,
    FAIconKey,
    FAIconCogs,
    FAIconComments,
    FAIconThumbsUp,
    FAIconThumbsDown,
    FAIconStarHalf,
    FAIconHeartEmpty,
    FAIconSignout,
    FAIconLinkedinSign,
    FAIconPushpin,
    FAIconExternalLink,
    FAIconSignin,
    FAIconTrophy,
    FAIconGithubSign,
    FAIconUploadAlt,
    FAIconLemon,
    FAIconPhone,
    FAIconCheckEmpty,
    FAIconBookmarkEmpty,
    FAIconPhoneSign,
    FAIconTwitter,
    FAIconFacebook,
    FAIconGithub,
    FAIconUnlock,
    FAIconCreditCard,
    FAIconRss,
    FAIconHdd,
    FAIconBullhorn,
    FAIconBell,
    FAIconCertificate,
    FAIconHandRight,
    FAIconHandLeft,
    FAIconHandUp,
    FAIconHandDown,
    FAIconCircleArrowLeft,
    FAIconCircleArrowRight,
    FAIconCircleArrowUp,
    FAIconCircleArrowDown,
    FAIconGlobe,
    FAIconWrench,
    FAIconTasks,
    FAIconFilter,
    FAIconBriefcase,
    FAIconFullscreen,
    FAIconGroup,
    FAIconLink,
    FAIconCloud,
    FAIconBeaker,
    FAIconCut,
    FAIconCopy,
    FAIconPaperClip,
    FAIconSave,
    FAIconSignBlank,
    FAIconReorder,
    FAIconListUl,
    FAIconListOl,
    FAIconStrikethrough,
    FAIconUnderline,
    FAIconTable,
    FAIconMagic,
    FAIconTruck,
    FAIconPinterest,
    FAIconPinterestSign,
    FAIconGooglePlusSign,
    FAIconGooglePlus,
    FAIconMoney,
    FAIconCaretDown,
    FAIconCaretUp,
    FAIconCaretLeft,
    FAIconCaretRight,
    FAIconColumns,
    FAIconSort,
    FAIconSortDown,
    FAIconSortUp,
    FAIconEnvelopeAlt,
    FAIconLinkedin,
    FAIconUndo,
    FAIconLegal,
    FAIconDashboard,
    FAIconCommentAlt,
    FAIconCommentsAlt,
    FAIconBolt,
    FAIconSitemap,
    FAIconUmbrella,
    FAIconPaste,
    FAIconUserMd,
    FAIconF116,
    FAIconF117,
    FAIconF118,
    FAIconF119,
    FAIconF120,
    FAIconF121,
    FAIconF122,
    FAIconF123,
    FAIconF124,
    FAIconF125,
    FAIconF126,
    FAIconF127,
    FAIconF128,
    FAIconF129,
    FAIconF130,
    FAIconF131,
    FAIconF132,
    FAIconF133,
    FAIconF134,
    FAIconF135,
    FAIconF136,
    FAIconF137,
    FAIconF138,
    FAIconF139,
    FAIconF140,
    FAIconF141,
    FAIconF142,
    FAIconF143,
    FAIconF144,
    FAIconF145,
    FAIconF146,
    FAIconF147,
    FAIconF148,
    FAIconF149,
    FAIconF150,
    FAIconF151,
    FAIconF152,
    FAIconF153
    
} FAIcon;

/**
 *  根据字符相应的枚举获取到字符
 *
 *  @param icon 字符枚举
 *  @param size 字体大小
 *
 *  @return 特殊字符
 */
+ (NSString *)stringFromAwesomeIcon:(FAIcon)icon;

/**
 *  得到特殊字符串的UIFont
 *
 *  @return UIFont
 */
+ (UIFont *) getFromAwesomeSize:(int) size;

/**
 *  替换左右空格
 *
 *  @return 字符串
 */
- (NSString *)trimWhitespace;

/**
 *  判断是否没空字符
 *
 *  @return BOOL
 */
- (BOOL)isEmpty;

/**
 *  MD5字串
 *
 *  @param input 原始字串
 *
 *  @return MD5字串
 */
+ (NSString *)md5HexDigest:(NSString*)input;


@end
