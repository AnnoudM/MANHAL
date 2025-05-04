import 'package:integration_test/integration_test.dart';
import 'package:flutter_test/flutter_test.dart';

import 'Login_test.dart' as login;

import 'EditChildEmptyName_test.dart' as edit_child_empty;
import 'EditChildInvalidName_test.dart' as edit_child_invalid;
import 'EditChildValidName_test.dart' as edit_child_valid;

import 'manage_content_lock_test.dart' as lock_content;
import 'manage_content_unlock_test.dart' as unlock_content;

import 'delete_child_test.dart' as delete_child;

import 'add_child_empty_name_test.dart' as add_child_empty_name;
import 'add_child_gender_required_test.dart' as add_child_gender;
import 'add_child_missing_age_test.dart' as add_child_age;
import 'add_child_valid_test.dart' as add_child_valid;
import 'add_child_without_photo_test.dart' as add_child_no_photo;

import 'create_account_empty_email_test.dart' as empty_email;
import 'create_account_empty_name_test.dart' as empty_name;
import 'create_account_empty_password_test.dart' as empty_password;
import 'create_account_invalid_email_test.dart' as invalid_email;
import 'create_account_mismatch_passwords_test.dart' as mismatch_passwords;
import 'create_account_test.dart' as create_account;

import 'Scan_clear_test.dart' as scan_clear;
import 'Scan_unclear_test.dart' as scan_unclear;

import 'view_ethical_value_test.dart' as ethical;
import 'view_number_activity_test.dart' as number_activity;
import 'view_number_activity_wrong_answer_test.dart' as number_wrong;
import 'view_number_activity_correct_test.dart' as number_correct;

import 'weak_password_test.dart' as weak_password;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('All integration tests', () {
    login.main();

    edit_child_empty.main();
    edit_child_invalid.main();
    edit_child_valid.main();

    lock_content.main(); 
    unlock_content.main(); 

    empty_email.main();
    empty_name.main();
    empty_password.main();
    invalid_email.main();
    mismatch_passwords.main();
    weak_password.main();
    create_account.main();

    number_activity.main();
    number_wrong.main();
    number_correct.main();
    delete_child.main();  

    scan_clear.main(); 
    scan_unclear.main();

    add_child_empty_name.main();
    add_child_gender.main();
    add_child_age.main();
    add_child_valid.main();
    add_child_no_photo.main(); 

    ethical.main();

  });
}
