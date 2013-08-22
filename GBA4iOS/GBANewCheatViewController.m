//
//  GBANewCheatViewController.m
//  GBA4iOS
//
//  Created by Riley Testut on 8/21/13.
//  Copyright (c) 2013 Riley Testut. All rights reserved.
//

#import "GBANewCheatViewController.h"

@interface NSString (RemoveWhitespace)

- (NSString *)stringByRemovingWhitespace;

@end

@implementation NSString (RemoveWhitespace)

// Doesn't try to remove all whitespace, but these are the only ones we have to worry about
- (NSString *)stringByRemovingWhitespace
{
    NSMutableString *text = [self mutableCopy];
    [text replaceOccurrencesOfString:@" " withString:@"" options:0 range:NSMakeRange(0, text.length)];
    [text replaceOccurrencesOfString:@"\n" withString:@"" options:0 range:NSMakeRange(0, text.length)];
    
    return text;
}

@end

@interface GBANewCheatViewController () <UITextViewDelegate, UITextFieldDelegate> {
    NSRange _selectionRange;
}

@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITextView *codeTextView;

- (IBAction)saveCheat:(UIBarButtonItem *)sender;
- (IBAction)cancelSavingNewCheat:(UIBarButtonItem *)sender;

@end

@implementation GBANewCheatViewController

- (id)init
{
    NSString *resourceBundlePath = [[NSBundle mainBundle] pathForResource:@"GBAResources" ofType:@"bundle"];
    NSBundle *resourceBundle = [NSBundle bundleWithPath:resourceBundlePath];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle:resourceBundle];
    
    
    self = [storyboard instantiateViewControllerWithIdentifier:@"newCheatViewController"];
    if (self)
    {
        // Custom initialization
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.nameTextField becomeFirstResponder];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)saveCheat:(UIBarButtonItem *)sender
{
    NSArray *codes = [self codesFromTextView];
    GBACheat *cheat = [[GBACheat alloc] initWithName:self.nameTextField.text codes:codes];
        
    if ([self.delegate respondsToSelector:@selector(newCheatViewController:didSaveCheat:)])
    {
        [self.delegate newCheatViewController:self didSaveCheat:cheat];
    }
}

- (IBAction)cancelSavingNewCheat:(UIBarButtonItem *)sender
{
    if ([self.delegate respondsToSelector:@selector(newCheatViewControllerDidCancel:)])
    {
        [self.delegate newCheatViewControllerDidCancel:self];
    }
}

- (NSArray *)codesFromTextView
{
    NSMutableArray *array = [[NSMutableArray alloc] init];
    
    NSMutableString *text = [[self.codeTextView.text stringByRemovingWhitespace] mutableCopy];
    
    while (text.length >= 16)
    {
        NSRange range = NSMakeRange(0, 16);
        NSString *code = [text substringWithRange:range];
        [array addObject:code];
        [text deleteCharactersInRange:range];
    }
    
    return array;
}

#pragma mark - UITextFieldDelegate

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [self.tableView scrollRectToVisible:CGRectMake(0, 0, self.view.bounds.size.width, 10) animated:YES];
}

#pragma mark - UITextViewDelegate

- (void)textViewDidBeginEditing:(UITextView *)textView
{
     [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:1] atScrollPosition:UITableViewScrollPositionTop animated:YES];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    NSInteger difference = textView.text.length - [textView.text stringByRemovingWhitespace].length;
        
    if (text.length > 0)
    {
        if ((range.location - difference + 1) % 8 == 0)
        {
            _selectionRange = NSMakeRange(range.location + 2, 0);
        }
        else
        {
            _selectionRange = NSMakeRange(range.location + 1, 0);
        }
    }
    else
    {
        _selectionRange = NSMakeRange(range.location, 0);
    }
    return YES;
}

- (void)textViewDidChange:(UITextView *)textView
{
    NSString *text = [textView.text stringByRemovingWhitespace];
    
    NSMutableString *formattedText = [NSMutableString string];
    
    for (int i = 0; i < (int)text.length; i++)
    {
        if (i > 0)
        {
            if ((i + 1) % 16 == 0)
            {
                [formattedText appendFormat:@"%c\n", [text characterAtIndex:i]];
            }
            else if ((i + 1) % 8 == 0)
            {
                [formattedText appendFormat:@"%c ", [text characterAtIndex:i]];
            }
            else
            {
                [formattedText appendFormat:@"%c", [text characterAtIndex:i]];
            }
        }
        else
        {
            [formattedText appendFormat:@"%c", [text characterAtIndex:i]];
        }
    }
    
    textView.text = formattedText;
    
    [textView setSelectedRange:_selectionRange];
    
}

@end