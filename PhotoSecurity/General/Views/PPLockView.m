//
//  PPLockView.m
//  GestureLock
//
//  Created by 王鹏 on 12-9-28.
//  Copyright (c) 2012年 pengjay.cn@gmail.com. All rights reserved.
//

#import "PPLockView.h"

#define startY 50
#define startX 35
#define PaddingX 35
#define PaddingY 35
#define Width 60
#define Height 60

@interface PPLockView ()



@end

@implementation PPLockView
@synthesize delegate = _delegate;

- (instancetype)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        
        self.backgroundColor = [UIColor clearColor];
        self.tipsLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 64, APP_WIDTH, 20)];
        self.tipsLabel.textAlignment = NSTextAlignmentCenter;
        self.tipsLabel.font = kFONT(kTitleName_PingFang_M, 15);
        self.tipsLabel.textColor = [UIColor colorWithHex:kWhiteColor];
        self.tipsLabel.text = NSLocalizedString(@"Please set gesture password.", nil);
        [self addSubview:self.tipsLabel];
        
		_selectedPointArray = [[NSMutableArray alloc]init];
		_passwd = [[NSMutableString alloc] init];
    
    }
    
    return self;
}

- (void)dealloc {
    
	[_selectedPointArray release];
	_selectedPointArray = nil;
	
	[_passwd release];
	_passwd = nil;
	[super dealloc];
}

- (CGPathRef)linePathStartAt:(CGPoint)startPoint End:(CGPoint)endPoint With:(CGFloat)lineWidth {
    
	CGMutablePathRef path = CGPathCreateMutable();
	CGPathMoveToPoint(path, nil, startPoint.x, startPoint.y);
	CGPathAddLineToPoint(path, nil, endPoint.x, endPoint.y);
	CGPathCloseSubpath(path);
	return path;
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    
	UITouch *touch = [touches anyObject];
	currentPoint = [touch locationInView:self];
    
    CGFloat startPonitX = APP_WIDTH/3 - 60;
    CGFloat startPonitY = APP_HEIGTH/2 - 150;
    CGPoint points[9] = {{startPonitX,startPonitY},
            {startPonitX + Width + PaddingX, startPonitY},
            {startPonitX + Width*2 + PaddingX*2, startPonitY},
            {startPonitX, startPonitY+Height+PaddingY},
            {startPonitX + Width + PaddingX, startPonitY+Height+PaddingY},
            {startPonitX + Width*2 + PaddingX*2, startPonitY+Height+PaddingY},
            {startPonitX, startPonitY+Height*2+PaddingY*2},
            {startPonitX + Width + PaddingX, startPonitY+Height*2+PaddingY*2},
            {startPonitX + Width*2 + PaddingX*2, startPonitY+Height*2+PaddingY*2}
        
    };

	for(int i = 0; i < 9; i++) {

        CGPoint p = points[i];
		CGRect rect = CGRectMake(p.x, p.y, Width, Height);
		
        if(CGRectContainsPoint(rect, currentPoint)){
            
			CGPoint ap = CGPointMake(p.x+Width/2, p.y+Height/2);
			NSString *curstr = NSStringFromCGPoint(ap);
			if(![_selectedPointArray containsObject:curstr]){
                
				[_selectedPointArray addObject:curstr];
				[_passwd appendFormat:@"%d", i];
			}
		}
	}
    
	[self setNeedsDisplay];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    
	if([_passwd length] > 0 && [_delegate respondsToSelector:@selector(lockViewUnlockWithPasswd:)]) {
        
		[_delegate lockViewUnlockWithPasswd:_passwd];
	}
    
	NSLog(@"%@", _passwd);
	[_selectedPointArray removeAllObjects];
	[_passwd setString:@""];
	[self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {

	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextSetLineWidth(context, 3.0f);
	CGContextSetStrokeColorWithColor(context, [[UIColor yellowColor] CGColor]);
	CGContextSetLineJoin(context, kCGLineJoinRound);
	
    if([_selectedPointArray count] > 0){
        
		int i = 0;
		for (NSString *posstr in _selectedPointArray) {
            
			CGPoint p = CGPointFromString(posstr);
			if (i == 0){
				CGContextMoveToPoint(context, p.x, p.y);
			}else{
				CGContextAddLineToPoint(context, p.x, p.y);
			}
			i++;
		}
		CGContextAddLineToPoint(context, currentPoint.x, currentPoint.y);
		CGContextStrokePath(context);
	}
    
    CGFloat startPonitX = APP_WIDTH/3 - 60;
    CGFloat startPonitY = APP_HEIGTH/2 - 150;
    CGPoint points[9] = {{startPonitX,startPonitY},
        {startPonitX + Width + PaddingX, startPonitY},
        {startPonitX + Width*2 + PaddingX*2, startPonitY},
        {startPonitX, startPonitY+Height+PaddingY},
        {startPonitX + Width + PaddingX, startPonitY+Height+PaddingY},
        {startPonitX + Width*2 + PaddingX*2, startPonitY+Height+PaddingY},
        {startPonitX, startPonitY+Height*2+PaddingY*2},
        {startPonitX + Width + PaddingX, startPonitY+Height*2+PaddingY*2},
        {startPonitX + Width*2 + PaddingX*2, startPonitY+Height*2+PaddingY*2}
    };
	
	for(int i = 0; i < 9; i++) {
		
        CGPoint point = points[i];
		CGPoint ap = CGPointMake(point.x + Width/2, point.y + Height/2);
		NSString *curstr = NSStringFromCGPoint(ap);
        if(![_selectedPointArray containsObject:curstr]){
			
            UIImage *img = [UIImage imageNamed:@"lock_btn_none.png"];
			[img drawAtPoint:CGPointMake(point.x, point.y)];
		}else{
			
            UIImage *img = [UIImage imageNamed:@"lock_btn_sel.png"];
			[img drawAtPoint:CGPointMake(point.x, point.y)];
		}
	}
}


@end
