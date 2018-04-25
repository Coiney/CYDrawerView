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

#import <UIKit/UIKit.h>

@class CYDrawerView;

@protocol CYDrawerViewDelegate <NSObject>
@optional
- (void)  drawerView:(nonnull CYDrawerView *)aDrawerView
didSelectItemAtIndex:(NSInteger)aIndex;
- (void)drawerViewDidOpen:(nonnull CYDrawerView *)aDrawerView;
- (void)drawerViewDidClose:(nonnull CYDrawerView *)aDrawerView;
@end

@protocol CYDrawerViewDataSource <NSObject>
@required
- (NSInteger)numberOfRowsInDrawerView:(nonnull CYDrawerView *)aDrawerView;
- (nonnull NSString *)drawerView:(nonnull CYDrawerView *)aDrawerView
                    titleForItem:(NSInteger)aIndex;  // Zero-indexed
@end

@interface CYDrawerView : UIView
@property(nonatomic, assign) CGFloat extensionDistance;
@property(nonatomic, assign) NSInteger selectedItem;
@property(nonatomic, assign, getter=isOpen) BOOL open;  // Animates
@property(nonatomic, weak, nullable) id<CYDrawerViewDelegate> delegate;
@property(nonatomic, weak, nullable) id<CYDrawerViewDataSource> dataSource;

// Use to customize appearance of toggle button and table view
@property(readonly, nonnull) UIButton *openButton;
@property(readonly, nonnull) UITableView *tableView;

- (nonnull instancetype)init;
- (nonnull instancetype)initWithFrame:(CGRect)aFrame;
- (nonnull instancetype)initWithCoder:(nonnull NSCoder *)aDecoder;

- (void)setOpen:(BOOL)aOpen animated:(BOOL)aAnimated;
@end
