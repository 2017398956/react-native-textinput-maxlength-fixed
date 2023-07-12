//
//  RCTBaseTextInputView+Helper.m
//  AwesomeProject
//
//  Created by nfl on 2023/7/11.
//

#import "RCTBaseTextInputView+Helper.h"
#import <React/RCTEventDispatcherProtocol.h>
#import <React/RCTTextAttributes.h>

@implementation RCTBaseTextInputView (Helper)

- (NSString *)textInputShouldChangeText:(NSString *)text inRange:(NSRange)range
{
  id<RCTEventDispatcherProtocol> _eventDispatcher = [self valueForKey:@"_eventDispatcher"];
  NSString *_Nullable _predictedText = [self valueForKey:@"_predictedText"];
  NSNumber *reactTag = [self valueForKey:@"reactTag"];
  NSNumber *_maxLength = [self valueForKey:@"maxLength"];
  NSInteger _nativeEventCount = [[self valueForKey:@"_nativeEventCount"] intValue];
  
  
  id<RCTBackedTextInputViewProtocol> backedTextInputView = self.backedTextInputView;
  
  if (!backedTextInputView.textWasPasted) {
    [_eventDispatcher sendTextEventWithType:RCTTextEventTypeKeyPress
                                   reactTag:reactTag
                                       text:nil
                                        key:text
                                 eventCount:_nativeEventCount];
  }

  if (_maxLength) {
    NSInteger allowedLength = MAX(
        _maxLength.integerValue - (NSInteger)backedTextInputView.attributedText.string.length + (NSInteger)range.length,
        0);

    if (text.length > allowedLength) {
      // 是否有高亮字符串
      UITextRange *selectedRange = [backedTextInputView markedTextRange];
      // 判断是否存在高亮字符
      UITextPosition *position = [backedTextInputView positionFromPosition:selectedRange.start offset:0];
      if (position) {
        return text;
      }
      
      // If we typed/pasted more than one character, limit the text inputted.
      if (text.length > 1) {
        if (allowedLength > 0) {
          // make sure unicode characters that are longer than 16 bits (such as emojis) are not cut off
          NSRange cutOffCharacterRange = [text rangeOfComposedCharacterSequenceAtIndex:allowedLength - 1];
          if (cutOffCharacterRange.location + cutOffCharacterRange.length > allowedLength) {
            // the character at the length limit takes more than 16bits, truncation should end at the character before
            allowedLength = cutOffCharacterRange.location;
          }
        }
        // Truncate the input string so the result is exactly maxLength
        NSString *limitedString = [text substringToIndex:allowedLength];
        NSMutableAttributedString *newAttributedText = [backedTextInputView.attributedText mutableCopy];
        // Apply text attributes if original input view doesn't have text.
        if (backedTextInputView.attributedText.length == 0) {
          newAttributedText = [[NSMutableAttributedString alloc]
              initWithString:[self.textAttributes applyTextAttributesToText:limitedString]
                  attributes:self.textAttributes.effectiveTextAttributes];
        } else {
            if(newAttributedText.length > _maxLength.intValue){
              [newAttributedText replaceCharactersInRange:NSMakeRange(_maxLength.intValue,      newAttributedText.length - _maxLength.intValue) withString:@""];
            }else{
              [newAttributedText replaceCharactersInRange:range withString:limitedString];
            }
        }
        backedTextInputView.attributedText = newAttributedText;
        _predictedText = newAttributedText.string;
        [self setValue:_predictedText forKey:@"_predictedText"];

        // Collapse selection at end of insert to match normal paste behavior.
        UITextPosition *insertEnd = [backedTextInputView positionFromPosition:backedTextInputView.beginningOfDocument
                                                                       offset:newAttributedText.length >= _maxLength.intValue?_maxLength.intValue : (range.location + allowedLength)];
        [backedTextInputView setSelectedTextRange:[backedTextInputView textRangeFromPosition:insertEnd
                                                                                  toPosition:insertEnd]
                                   notifyDelegate:YES];

        [self textInputDidChange];
      }

      return nil; // Rejecting the change.
    }
  }

  NSString *previousText = [backedTextInputView.attributedText.string copy] ?: @"";

  if (range.location + range.length > backedTextInputView.attributedText.string.length) {
    _predictedText = backedTextInputView.attributedText.string;
  } else {
    _predictedText = [backedTextInputView.attributedText.string stringByReplacingCharactersInRange:range
                                                                                        withString:text];
  }
  [self setValue:_predictedText forKey:@"_predictedText"];
  _nativeEventCount = [[self valueForKey:@"_nativeEventCount"] intValue];
  if (self.onTextInput) {
    self.onTextInput(@{
      // We copy the string here because if it's a mutable string it may get released before we stop using it on a
      // different thread, causing a crash.
      @"text" : [text copy],
      @"previousText" : previousText,
      @"range" : @{@"start" : @(range.location), @"end" : @(range.location + range.length)},
      @"eventCount" : @(_nativeEventCount),
    });
  }

  return text; // Accepting the change.
}

@end
