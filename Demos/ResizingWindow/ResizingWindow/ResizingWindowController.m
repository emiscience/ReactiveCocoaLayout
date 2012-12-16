//
//	ResizingWindowController.m
//	ResizingWindow
//
//	Created by Justin Spahr-Summers on 2012-12-12.
//	Copyright (c) 2012 GitHub. All rights reserved.
//

#import "ResizingWindowController.h"

@interface ResizingWindowController ()

@property (nonatomic, strong, readonly) NSView *contentView;

@end

@implementation ResizingWindowController

#pragma mark Properties

- (NSView *)contentView {
	return self.window.contentView;
}

#pragma mark Lifecycle

- (id)init {
	return [self initWithWindowNibName:@"ResizingWindow"];
}

- (void)windowDidLoad {
	[super windowDidLoad];

	NSTextField *nameLabel = [self labelWithString:NSLocalizedString(@"Name", @"")];
	NSTextField *emailLabel = [self labelWithString:NSLocalizedString(@"Email Address", @"")];
	CGFloat labelWidth = fmax(CGRectGetWidth(nameLabel.bounds), CGRectGetWidth(emailLabel.bounds));

	NSTextField *nameField = [self textFieldWithString:@""];
	NSTextField *emailField = [self textFieldWithString:@""];

	RACTupleUnpack(id<RCLSignal> nameRect, id<RCLSignal> emailRect) = [[self.contentView.rcl_frameSignal
		insetWidth:32 height:16]
		divideWithAmount:CGRectGetHeight(nameField.bounds) padding:8 fromEdge:CGRectMaxYEdge];

	RACTuple *nameTuple = [[nameRect animateWithDuration:0.5] divideWithAmount:labelWidth padding:8 fromEdge:CGRectMinXEdge];
	RAC(nameLabel, frame) = nameTuple[0];

	// Don't animate setting the initial frame.
	RAC(nameField, frame) = [nameTuple[1] take:1];

	// Can't lift this until https://github.com/github/ReactiveCocoa/issues/186
	// is implemented.
	[[nameTuple[1] skip:1] subscribeNext:^(NSValue *frame) {
		[nameField.animator setFrame:frame.med_rectValue];
	}];

	RACTuple *emailTuple = [[emailRect
		sliceWithAmount:CGRectGetHeight(emailField.bounds) fromEdge:CGRectMaxYEdge]
		divideWithAmount:labelWidth padding:8 fromEdge:CGRectMinXEdge];

	RAC(emailLabel, frame) = emailTuple[0];
	RAC(emailField, frame) = emailTuple[1];
}

#pragma mark View Creation

- (NSTextField *)labelWithString:(NSString *)string {
	NSTextField *label = [[NSTextField alloc] initWithFrame:NSZeroRect];
	label.editable = NO;
	label.selectable = NO;
	label.bezeled = NO;
	label.drawsBackground = NO;
	label.stringValue = string;
	[label sizeToFit];

	[self.contentView addSubview:label];
	return label;
}

- (NSTextField *)textFieldWithString:(NSString *)string {
	NSTextField *textField = [[NSTextField alloc] initWithFrame:NSZeroRect];
	textField.stringValue = string;
	[textField sizeToFit];

	[self.contentView addSubview:textField];
	return textField;
}

@end
