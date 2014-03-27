Spree::CheckoutController.class_eval do
  private
    def completion_route
      if is_omnikassa_payment?
        url_for :controller => 'omnikassa',
                :action => 'start',
                :payment_id => payment.id,
                :token => @order.token
      else
        super
      end
    end

    def payment
      @order.payments.first
    end

    def is_omnikassa_payment?
      @order.payments.all? do |payment|
        payment.payment_method.class == Spree::BillingIntegration::Omnikassa
      end
    end
end