import 'package:get/get_navigation/src/root/internacionalization.dart';

class AppTranslation extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
    'fr_FR': {
      'sign_in': 'Se connecter',
      'connect_button_text': 'Se connecter',
      'email': 'E-mail',
      'password': 'Mot de passe',
      'forgot_password': 'Avez-vous oublié votre mot de passe ?',
      'no_account': "Vous n'avez pas de compte ?",
      'sign_up': 'S’inscrire',
      'continue_with_google': 'Continuer avec Google',
    },
    'en_EN': {
      'sign_in': 'Sign in',
      'connect_button_text': 'Sign in',
      'email': 'Email',
      'password': 'Password',
      'forgot_password': 'Did You Forget Your Password?',
      'no_account': "Don't have an account?",
      'sign_up': 'Sign Up',
      'continue_with_google': 'Continue with Google',
    },
    'ar_AR': {
      'sign_in': 'تسجيل الدخول',
      'connect_button_text': 'تسجيل الدخول',
      'email': 'البريد الإلكتروني',
      'password': 'كلمة المرور',
      'forgot_password': 'هل نسيت كلمة المرور؟',
      'no_account': 'ليس لديك حساب؟',
      'sign_up': 'اشترك',
      'continue_with_google': 'المتابعة مع جوجل',
    },
  };
}
