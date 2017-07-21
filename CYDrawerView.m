/*
 * Copyright (c) 2017 Coiney
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */

#import "CYDrawerView.h"

#if !defined(CLAMP)
#   define CLAMP(val, min, max) MAX((min), MIN((val), (max)))
#endif

CGFloat const kDefaultExtensionDistance = 300;

@interface CYDrawerView () <UITableViewDataSource, UITableViewDelegate> {
    CGFloat _offset;
    UIButton *_openCloseButton;
    NSLayoutConstraint *_bottomSpace;
}
@end

@implementation CYDrawerView
@synthesize selectedItem = _selectedItem;
@dynamic open;

- (instancetype)initWithFrame:(CGRect const)aFrame
{
    if ((self = [super initWithFrame:aFrame])) {
        [self _init];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder * const)aDecoder
{
    if ((self = [super initWithCoder:aDecoder])) {
        [self _init];
    }
    return self;
}

- (void)_init
{
    self.extensionDistance = kDefaultExtensionDistance;
    
    UIPanGestureRecognizer * const panRecognizer =
        [[UIPanGestureRecognizer alloc] initWithTarget:self
                                                action:@selector(drawerDidPan:)];
    [self addGestureRecognizer:panRecognizer];
    self.clipsToBounds = NO;

    _openCloseButton = [UIButton new];
    [_openCloseButton addTarget:self
                         action:@selector(toggleOpen:)
               forControlEvents:UIControlEventTouchUpInside];
    _openCloseButton.backgroundColor = [UIColor grayColor];
    _openCloseButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:_openCloseButton];
    
    _tableView = [UITableView new];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    [self addSubview:_tableView];
}

- (void)didMoveToWindow
{
    NSUInteger index =
        [self.superview.constraints indexOfObjectPassingTest:^BOOL(id const aConstraint, NSUInteger const aIdx, BOOL *oStop) {
            BOOL ret = ([aConstraint isMemberOfClass:[NSLayoutConstraint class]] &&
                        [(NSLayoutConstraint *)aConstraint secondAttribute] == NSLayoutAttributeBottom);
            if (ret) {
                *oStop = YES;
            }
            return ret;
        }];
    _bottomSpace= index != NSNotFound ? self.superview.constraints[index] : nil;
    
    NSAssert(_bottomSpace, @"%@ must have a bottom space constraint", NSStringFromClass([self class]));
    
    self.selectedItem = 0;
}

- (UIView *)hitTest:(CGPoint const)aPoint withEvent:(UIEvent * const)aEvent
{
    if (CGRectContainsPoint(_tableView.frame, aPoint)) {
        return _tableView;
    }
    return [super hitTest:aPoint withEvent:aEvent];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    _openCloseButton.frame = self.bounds;
    [_openCloseButton setTitle:[_dataSource drawerView:self titleForItem:_selectedItem]
                      forState:UIControlStateNormal];
    _tableView.frame = (CGRect) { 0, self.bounds.size.height, self.bounds.size.width, _extensionDistance };
}

- (void)toggleOpen:(id const)aSender
{
    self.open = self.isOpen ? NO : YES;
}

- (BOOL)isOpen
{
    return _bottomSpace.constant > 0;
}

- (void)setOpen:(BOOL const)aFlag
{
    [self setOpen:aFlag animated:YES];
}

- (NSInteger)selectedItem
{
    return _selectedItem;
}

- (void)setSelectedItem:(NSInteger const)aItem
{
    UITableViewCell * cell = [_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:_selectedItem inSection:0]];
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell = [_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:aItem inSection:0]];
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
    
    _selectedItem = aItem;
}

- (void)setOpen:(BOOL const)aOpen animated:(BOOL const)aAnimated
{
    if ((aOpen && _bottomSpace.constant < _extensionDistance) ||
       (!aOpen && _bottomSpace.constant > 0))
    {
        _bottomSpace.constant = aOpen ? _extensionDistance : 0;
        
        [UIView animateWithDuration:aAnimated ? 0.2 : 0
                              delay:0
             usingSpringWithDamping:0.74
              initialSpringVelocity:0
                            options:0
                         animations:^{
                             [self.superview layoutIfNeeded];
                         }
                         completion:nil];
        
        if (aOpen) {
            if ([_delegate respondsToSelector:@selector(drawerViewDidOpen:)]) {
                [_delegate drawerViewDidOpen:self];
            }
        } else {
            if ([_delegate respondsToSelector:@selector(drawerViewDidClose:)]) {
                [_delegate drawerViewDidClose:self];
            }
        }
    }
}

- (void)drawerDidPan:(UIPanGestureRecognizer * const)aRecognizer
{
    static CGFloat initialOffset;
    BOOL up;
    
    switch (aRecognizer.state) {
        case UIGestureRecognizerStateBegan:
            initialOffset = _bottomSpace.constant;
            break;
        case UIGestureRecognizerStateChanged:
            _bottomSpace.constant = CLAMP(
                initialOffset - [aRecognizer translationInView:self].y, 0, _extensionDistance
            );
            break;
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateFailed:
        {
            up = [aRecognizer velocityInView:self].y <= 0;
            if (up) {
                self.open = YES;
            } else {
                self.open = NO;
            }
            [UIView animateWithDuration:0.2
                                  delay:0
                 usingSpringWithDamping:0.74
                  initialSpringVelocity:0
                                options:0
                             animations:^{
                                 [self layoutIfNeeded];
                             }
                             completion:nil];
            break;
        }
        default:
            break;
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView * const)aTableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView * const)aTableView
 numberOfRowsInSection:(NSInteger const)aSection
{
    return [_dataSource numberOfRowsInDrawerView:self];
}

- (UITableViewCell *)tableView:(UITableView * const)aTableView
         cellForRowAtIndexPath:(NSIndexPath * const)aIndexPath
{
    UITableViewCell * const cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1
                                                          reuseIdentifier:nil];
    cell.textLabel.text = [_dataSource drawerView:self titleForItem:aIndexPath.row];
    if (aIndexPath.row == _selectedItem) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    return cell;
}

#pragma mark - Table view delegate

- (void)      tableView:(UITableView * const)aTableView
didSelectRowAtIndexPath:(NSIndexPath * const)aIndexPath
{
    [aTableView deselectRowAtIndexPath:aIndexPath animated:YES];
    [_openCloseButton setTitle:[_dataSource drawerView:self titleForItem:aIndexPath.row]
                      forState:UIControlStateNormal];
    self.selectedItem = aIndexPath.row;

    if ([_delegate respondsToSelector:@selector(drawerView:didSelectItemAtIndex:)]) {
        [_delegate drawerView:self didSelectItemAtIndex:aIndexPath.row];
    }
}

@end
