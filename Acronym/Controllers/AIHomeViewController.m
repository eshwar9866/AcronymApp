//
//  AIHomeViewController.m
//  Acronym
//
//  Created by Eshwar Chaitanya Govindaraju on 02/23/17.
//  Copyright (c) 2017 Eshwar Chaitanya Govindaraju All rights reserved.
//

#import "AIHomeViewController.h"
#import "AIConstants.h"
#import "AINetworkClient.h"
#import "MBProgressHUD.h"
#import "AIAcronym.h"
#import "AIMeaning.h"
#import "AIVariationsViewController.h"

@interface AIHomeViewController ()<UITextFieldDelegate,UITableViewDataSource,UITableViewDelegate>

@property (nonatomic, strong) AIAcronym *acronym;
@property (nonatomic, weak) IBOutlet UITableView *acronymTableView;
@property (nonatomic, weak) IBOutlet UITextField *acronymEntryField;
@property (nonatomic, strong) NSCharacterSet *disallowedCharacters;

@end

@implementation AIHomeViewController

#pragma mark- Life cycle methods
- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIImage * Image = [UIImage imageNamed:@"Acronym.jpg"];
    self.view.layer.contents = (__bridge id _Nullable)(Image.CGImage);
    [self resetContent];
    
    // Allow only alpha-numeric characters in textfield
    self.disallowedCharacters = [[NSCharacterSet alphanumericCharacterSet] invertedSet];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

#pragma mark - UITextField delegate methods
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [self resetContent];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    if(![textField.text isEqualToString:@""]){
        
        [self fetchMeaningsForAcronym:textField.text];
    }
   
    return YES;
    
}

/*
 * delegate checks the validity of user text  entry.
 * It checks for below 3 conditions
 * 1. If entered text is less than MAXLENGTH 
 * (MAXLENGTH is set to 30. This value is configurable.)
 * 2. accept return key
 * 3. accept only alphabets and numeric characters.
*/

-(BOOL)textField:(UITextField *) textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    NSUInteger oldLength = [textField.text length];
    NSUInteger replacementLength = [string length];
    NSUInteger rangeLength = range.length;
    NSUInteger newLength = oldLength - rangeLength + replacementLength;
    
    
    return (newLength <= MAXLENGTH || ([string rangeOfString: @"\n"].location != NSNotFound)) && ([string rangeOfCharacterFromSet:self.disallowedCharacters].location == NSNotFound);
}

#pragma mark- UITableView Datasource methods
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.acronym.meanings.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *reuseIdentifier = @"CellIdentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    
    AIMeaning *meaning = [self.acronym.meanings objectAtIndex:indexPath.row];
    cell.textLabel.text = meaning.meaning;
    cell.detailTextLabel.text = [NSString stringWithFormat:NSLocalizedString(@"MeaningsSubtitleText", @""),(long)meaning.since, (long)meaning.frequency];
    [cell.textLabel setTextColor:[UIColor lightTextColor]];
    [cell.detailTextLabel setTextColor:[UIColor lightGrayColor]];
    
    return cell;
}

#pragma mark- UITableView Delegate methods

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 44.0;
}

-(UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    static NSString *headerIdentifier = @"HeaderIdentifier";
    UITableViewCell *headerView = [tableView dequeueReusableCellWithIdentifier:headerIdentifier];
    
    headerView.textLabel.text = [NSString stringWithFormat:NSLocalizedString(@"HeaderText", @""),self.acronymEntryField.text];
    [headerView.textLabel setTextColor:[UIColor blueColor]];
    
    return headerView;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
   
    // Calculate height required for title text and subtitle text. Then add padding above and below.
    AIMeaning *meaning = [self.acronym.meanings objectAtIndex:indexPath.row];
    
    CGFloat titleHeight = [self heightForText:[meaning meaning] withFont:labelBoldTextFont];
    
     NSString *subTitleText = [NSString stringWithFormat:NSLocalizedString(@"MeaningsSubtitleText", @""),(long)meaning.since, (long)meaning.frequency];
    CGFloat subtitleHeight = [self heightForText:subTitleText withFont:descriptionTextFont];
   
    return titleHeight + subtitleHeight + 2 * cellVerticalPadding;
    
}


#pragma mark - Web service
-(void) fetchMeaningsForAcronym: (NSString *) acronym {
  
    NSDictionary *parameters = @{@"sf": acronym};
    
    // show loading indicator when web service is made
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    [[AINetworkClient sharedManager] getResponseForURLString:AIBaseURL
                                                  Parameters:parameters
                                                     success:^(NSURLSessionDataTask *task, AIAcronym *acronym) {
                                                         
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        self.acronym = acronym;
        if (self.acronym && self.acronym.meanings.count > 0) {
            [self.acronymTableView setHidden:NO];
            [self.acronymTableView setContentOffset:CGPointZero animated:NO];
            [self.acronymTableView reloadData];
        }
        else{
            // show no results alerts
            [self showErrorAlertWithTitle:NSLocalizedString(@"NoResultsTitle", @"") message:[NSString stringWithFormat:NSLocalizedString(@"NoResultsMessage", @""),self.acronymEntryField.text]];
        }
        
    }
    failure:^(NSURLSessionDataTask *task, NSError *error) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        
        // show error alert with error description
        [self showErrorAlertWithTitle:nil message:error.localizedDescription];
        
    }];
    
}

#pragma mark - Helper methods

-(void) resetContent{
    [self.acronymTableView setHidden:YES];
    self.acronym = nil;
}

-(CGFloat) heightForText:(NSString *) text withFont:(UIFont *) font {
    NSDictionary *attributes = @{NSFontAttributeName: font};
    
    CGRect rect = [text boundingRectWithSize:CGSizeMake(self.acronymTableView.frame.size.width - cellHorizontalWaste, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil];
    return rect.size.height;
}

#pragma mark - Error handling

-(void)showErrorAlertWithTitle:(NSString *) title message:(NSString *) message{
    
    UIAlertController *alertController = [UIAlertController  alertControllerWithTitle:title  message:message  preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self dismissViewControllerAnimated:YES completion:nil];
        
    }]];
    [self presentViewController:alertController animated:YES completion:nil];

}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.

    if ([segue.identifier isEqualToString:@"VariationsIdentifier"]) {
        NSIndexPath *indexPath = [self.acronymTableView indexPathForSelectedRow];
        AIVariationsViewController *destinationViewController = [segue destinationViewController];
        destinationViewController.meaning = [self.acronym.meanings objectAtIndex:indexPath.row];
    }
    
}


@end
