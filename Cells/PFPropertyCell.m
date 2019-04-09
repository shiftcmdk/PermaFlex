#import "PFPropertyCell.h"

@interface PFPropertyCell () <UITextFieldDelegate>
@end

@implementation PFPropertyCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.segmentedControl = [[[UISegmentedControl alloc] initWithItems:@[@"Equals", @"Contains"]] autorelease];
        self.segmentedControl.translatesAutoresizingMaskIntoConstraints = NO;
        self.segmentedControl.selectedSegmentIndex = 0;
        [self.segmentedControl addTarget:self action:@selector(segmentedControlDidChange:) forControlEvents:UIControlEventValueChanged];

        [self.contentView addSubview:self.segmentedControl];

        [self.segmentedControl.leadingAnchor constraintEqualToAnchor:self.contentView.layoutMarginsGuide.leadingAnchor].active = YES;
        [self.segmentedControl.trailingAnchor constraintEqualToAnchor:self.contentView.layoutMarginsGuide.trailingAnchor].active = YES;
        [self.segmentedControl.topAnchor constraintEqualToAnchor:self.contentView.topAnchor constant:8.0].active = YES;

        self.propertyTextField = [[[UITextField alloc] init] autorelease];
        self.propertyTextField.translatesAutoresizingMaskIntoConstraints = NO;
        self.propertyTextField.placeholder = @"Property/Ivar";

        [self.contentView addSubview:self.propertyTextField];

        [self.propertyTextField.leadingAnchor constraintEqualToAnchor:self.contentView.layoutMarginsGuide.leadingAnchor].active = YES;
        [self.propertyTextField.trailingAnchor constraintEqualToAnchor:self.contentView.centerXAnchor].active = YES;
        [self.propertyTextField.topAnchor constraintEqualToAnchor:self.segmentedControl.bottomAnchor constant:8.0].active = YES;
        [self.propertyTextField.heightAnchor constraintEqualToConstant:44.0].active = YES;

        self.valueTextField = [[[UITextField alloc] init] autorelease];
        self.valueTextField.translatesAutoresizingMaskIntoConstraints = NO;
        self.valueTextField.placeholder = @"Value";
        self.valueTextField.textAlignment = NSTextAlignmentRight;

        [self.contentView addSubview:self.valueTextField];

        [self.valueTextField.leadingAnchor constraintEqualToAnchor:self.propertyTextField.trailingAnchor].active = YES;
        [self.valueTextField.trailingAnchor constraintEqualToAnchor:self.contentView.layoutMarginsGuide.trailingAnchor].active = YES;
        [self.valueTextField.topAnchor constraintEqualToAnchor:self.propertyTextField.topAnchor].active = YES;
        [self.valueTextField.bottomAnchor constraintEqualToAnchor:self.propertyTextField.bottomAnchor].active = YES;

        self.currentValueLabel = [[[UILabel alloc] init] autorelease];
        self.currentValueLabel.translatesAutoresizingMaskIntoConstraints = NO;
        self.currentValueLabel.textColor = [[self.valueTextField valueForKey:@"_placeholderLabel"] textColor];
        self.currentValueLabel.text = @"Current value:";
        self.currentValueLabel.font = [UIFont systemFontOfSize:12.0];
        self.currentValueLabel.numberOfLines = 0;

        [self.contentView addSubview:self.currentValueLabel];

        [self.currentValueLabel.topAnchor constraintEqualToAnchor:self.propertyTextField.bottomAnchor constant:8.0].active = YES;
        [self.currentValueLabel.bottomAnchor constraintEqualToAnchor:self.contentView.bottomAnchor constant:-8.0].active = YES;
        [self.currentValueLabel.leadingAnchor constraintEqualToAnchor:self.contentView.layoutMarginsGuide.leadingAnchor].active = YES;
        [self.currentValueLabel.trailingAnchor constraintEqualToAnchor:self.contentView.layoutMarginsGuide.trailingAnchor].active = YES;

        [self.propertyTextField addTarget:self action:@selector(propertyTextFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
        [self.valueTextField addTarget:self action:@selector(valueTextFieldDidChange:) forControlEvents:UIControlEventEditingChanged];

        self.propertyTextField.delegate = self;
        self.valueTextField.delegate = self;

        self.propertyTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        self.propertyTextField.autocorrectionType = UITextAutocorrectionTypeNo;
        self.propertyTextField.spellCheckingType = UITextSpellCheckingTypeNo;
        self.propertyTextField.returnKeyType = UIReturnKeyDone;

        self.valueTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        self.valueTextField.autocorrectionType = UITextAutocorrectionTypeNo;
        self.valueTextField.spellCheckingType = UITextSpellCheckingTypeNo;
        self.valueTextField.returnKeyType = UIReturnKeyDone;
    }

    return self;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    
    return YES;
}

-(void)propertyTextFieldDidChange:(UITextField *)sender {
    if (self.delegate) {
        [self.delegate propertyDidChange:self.propertyTextField.text cell:self];
    }
}

-(void)segmentedControlDidChange:(UISegmentedControl *)sender {
    if (self.delegate) {
        [self.delegate segmentedControlDidChange:self.segmentedControl.selectedSegmentIndex cell:self];
    }
}

-(void)valueTextFieldDidChange:(UITextField *)sender {
    if (self.delegate) {
        [self.delegate valueDidChange:self.valueTextField.text cell:self];
    }
}

-(void)configureWithProperty:(PFProperty *)prop currentValue:(NSString *)value {
    self.segmentedControl.selectedSegmentIndex = prop.equals ? 0 : 1;
    self.propertyTextField.text = prop.key;
    self.valueTextField.text = prop.value;

    if (prop.valid) {
        self.currentValueLabel.text = [NSString stringWithFormat:@"Current value: %@", value];
        self.currentValueLabel.textColor = [UIColor blackColor];
    } else {
        self.currentValueLabel.text = [NSString stringWithFormat:@"Current value: %@", value];
        self.currentValueLabel.textColor = [UIColor redColor];
    }
}

-(void)dealloc {
    [self.segmentedControl removeFromSuperview];

    self.segmentedControl = nil;

    [self.propertyTextField removeFromSuperview];

    self.propertyTextField = nil;

    [self.valueTextField removeFromSuperview];

    self.valueTextField = nil;

    [self.currentValueLabel removeFromSuperview];

    self.currentValueLabel = nil;

    [super dealloc];
}

@end