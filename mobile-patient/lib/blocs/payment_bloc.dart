import 'package:client_pharmanathi/Repository/payment_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../views/widgets/payment_webview.dart';

// Events
@immutable
abstract class PaymentEvent {}

class InitializePayment extends PaymentEvent {
  final int amount;
  final BuildContext context;

  InitializePayment(this.amount, this.context);
}

class VerifyPayment extends PaymentEvent {
  final String reference;

  VerifyPayment(this.reference);
}

// States
@immutable
abstract class PaymentState {}

class PaymentInitial extends PaymentState {}

class PaymentLoading extends PaymentState {}

class PaymentSuccess extends PaymentState {}

class PaymentFailure extends PaymentState {
  final String error;

  PaymentFailure(this.error);
}

// BLoC
class PaymentBloc extends Bloc<PaymentEvent, PaymentState> {
  final PaymentRepository paymentRepository;
  final BuildContext context; // Added BuildContext here

  PaymentBloc(this.paymentRepository, this.context) : super(PaymentInitial()) {
    on<InitializePayment>(_onInitializePayment);
    on<VerifyPayment>(_onVerifyPayment);
  }

  Future<void> _onInitializePayment(InitializePayment event, Emitter<PaymentState> emit) async {
    emit(PaymentLoading());
    try {
      String authorizationUrl = await paymentRepository.initializePayment(event.context, event.amount);
      Navigator.push(
        event.context,
        MaterialPageRoute(
          builder: (context) => PaymentWebView(
            authorizationUrl: authorizationUrl,
            onPaymentCompleted: () {
              Navigator.pop(event.context);
              final reference = extractReferenceFromUrl(authorizationUrl);
              add(VerifyPayment(reference));
            },
          ),
        ),
      );
    } catch (e) {
      emit(PaymentFailure(e.toString()));
    }
  }

  Future<void> _onVerifyPayment(VerifyPayment event, Emitter<PaymentState> emit) async {
    emit(PaymentLoading());
    try {
      bool verified = await paymentRepository.verifyPayment(context, event.reference); // Use the context here
      if (verified) {
        emit(PaymentSuccess());
      } else {
        emit(PaymentFailure("Payment verification failed"));
      }
    } catch (e) {
      emit(PaymentFailure(e.toString()));
    }
  }

  String extractReferenceFromUrl(String url) {
    final uri = Uri.parse(url);
    return uri.queryParameters['reference'] ?? '';
  }
}
