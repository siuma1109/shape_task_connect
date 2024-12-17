import 'package:flutter_test/flutter_test.dart';
import 'package:shape_task_connect/utils/validators.dart';

void main() {
  group('Validators', () {
    group('email', () {
      test('should return error message when email is null', () {
        expect(Validators.email(null), 'Please enter your email');
      });

      test('should return error message when email is empty', () {
        expect(Validators.email(''), 'Please enter your email');
      });

      test('should return error message when email format is invalid', () {
        expect(
          Validators.email('invalid_email'),
          'Please enter a valid email address',
        );
        expect(
          Validators.email('test@'),
          'Please enter a valid email address',
        );
        expect(
          Validators.email('test@.com'),
          'Please enter a valid email address',
        );
      });

      test('should return null when email format is valid', () {
        expect(Validators.email('test@example.com'), null);
        expect(Validators.email('username@domain.co.uk'), null);
        expect(Validators.email('userlabel@domain.com'), null);
      });
    });

    group('password', () {
      test('should return error message when password is null', () {
        expect(Validators.password(null), 'Please enter your password');
      });

      test('should return error message when password is empty', () {
        expect(Validators.password(''), 'Please enter your password');
      });

      test(
          'should return error message when password is less than 6 characters',
          () {
        expect(Validators.password('12345'),
            'Password must be at least 6 characters');
      });

      test('should return null when password is valid', () {
        expect(Validators.password('123456'), null);
        expect(Validators.password('strongpassword'), null);
      });
    });

    group('required', () {
      test('should return error message when value is null', () {
        expect(Validators.required(null, 'username'),
            'Please enter your username');
      });

      test('should return error message when value is empty', () {
        expect(
            Validators.required('', 'username'), 'Please enter your username');
      });

      test('should return null when value is provided', () {
        expect(Validators.required('John', 'username'), null);
      });
    });
  });
}
