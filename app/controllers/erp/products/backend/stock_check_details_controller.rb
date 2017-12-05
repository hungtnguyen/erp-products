module Erp
  module Products
    module Backend
      class StockCheckDetailsController < Erp::Backend::BackendController
        def stock_check_line_form
          @stock_check_detail = StockCheckDetail.new
          @stock_check_detail.product_id = params[:add_value]

          @stock_check_detail.state = ((params[:form].present? and params[:form][:default_state].present?) ? Erp::Products::State.find(params[:form][:default_state]) : nil)

          render partial: params[:partial], locals: {
            stock_check_detail: @stock_check_detail,
            uid: helpers.unique_id()
          }
        end
      end
    end
  end
end
