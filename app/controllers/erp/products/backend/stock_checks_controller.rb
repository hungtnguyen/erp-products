module Erp
  module Products
    module Backend
      class StockChecksController < Erp::Backend::BackendController
        before_action :set_stock_check, only: [:stock_check_confirm, :archive, :unarchive, :show, :edit, :update, :destroy]
        before_action :set_stock_checks, only: [:delete_all, :archive_all, :unarchive_all]

        # GET /stock_checks
        def index
        end

        # POST /stock_checks/list
        def list
          @stock_checks = StockCheck.search(params).paginate(:page => params[:page], :per_page => 3)

          render layout: nil
        end

        # GET /stock_checks/1
        def show
        end

        # GET /stock_checks/new
        def new
          @stock_check = StockCheck.new
          @stock_check.adjustment_date = Time.now
          @stock_check.employee = current_user
        end

        # GET /stock_checks/1/edit
        def edit
        end

        # POST /stock_checks
        def create
          @stock_check = StockCheck.new(stock_check_params)
          @stock_check.creator = current_user

          if @stock_check.save
            if request.xhr?
              render json: {
                status: 'success',
                text: @stock_check.code,
                value: @stock_check.id
              }
            else
              redirect_to erp_products.backend_stock_checks_path, notice: t('.success')
            end
          else
            render :new
          end
        end

        # PATCH/PUT /stock_checks/1
        def update
          if @stock_check.update(stock_check_params)
            if request.xhr?
              render json: {
                status: 'success',
                text: @stock_check.code,
                value: @stock_check.id
              }
            else
              redirect_to erp_products.backend_stock_checks_path, notice: t('.success')
            end
          else
            render :edit
          end
        end

        # DELETE /stock_checks/1
        def destroy
          @stock_check.destroy

          respond_to do |format|
            format.html { redirect_to erp_products.backend_stock_checks_path, notice: t('.success') }
            format.json {
              render json: {
                'message': t('.success'),
                'type': 'success'
              }
            }
          end
        end

        def archive
          @stock_check.archive

          respond_to do |format|
          format.json {
            render json: {
            'message': t('.success'),
            'type': 'success'
            }
          }
          end
        end

        def unarchive
          @stock_check.unarchive

          respond_to do |format|
          format.json {
            render json: {
            'message': t('.success'),
            'type': 'success'
            }
          }
          end
        end

        # DELETE /stock_checks/delete_all?ids=1,2,3
        def delete_all
          @stock_checks.destroy_all

          respond_to do |format|
            format.json {
              render json: {
                'message': t('.success'),
                'type': 'success'
              }
            }
          end
        end

        # Archive /stock_checks/archive_all?ids=1,2,3
        def archive_all
          @stock_checks.archive_all

          respond_to do |format|
            format.json {
              render json: {
                'message': t('.success'),
                'type': 'success'
              }
            }
          end
        end

        # Unarchive /stock_checks/unarchive_all?ids=1,2,3
        def unarchive_all
          @stock_checks.unarchive_all

          respond_to do |format|
            format.json {
              render json: {
                'message': t('.success'),
                'type': 'success'
              }
            }
          end
        end

        # Confirm /stock_checks/stock_check_confirm?id=1
        def stock_check_confirm
          @stock_check.stock_check_confirm

          respond_to do |format|
          format.json {
            render json: {
            'message': t('.success'),
            'type': 'success'
            }
          }
          end
        end

        def dataselect
          respond_to do |format|
            format.json {
              render json: StockCheck.dataselect(params[:keyword])
            }
          end
        end

        def ajax_stock_col
          @warehouse = Erp::Warehouses::Warehouse.where(id: params[:datas][0]).first
          @product = Erp::Products::Product.where(id: params[:datas][1]).first
          @state = Erp::Products::State.where(id: params[:datas][2]).first
          @stock = @product.get_stock(warehouse: @warehouse, state: @state)
          @uid = params[:datas][3]
          render layout: false
        end

        def form_check_details
          @stock_check = StockCheck.new()

          # product query
          @product_query = Erp::Products::Product.joins(:category)

          if params[:form_data].present?
            form_data = params[:form_data]
            # get categories
            category_ids = form_data[:categories].present? ? form_data[:categories] : nil
            @categories = Erp::Products::Category.where(id: category_ids)

            # get diameters
            diameter_ids = form_data[:diameters].present? ? form_data[:diameters] : nil
            @diameters = Erp::Products::PropertiesValue.where(id: diameter_ids)

            # get diameters
            letter_ids = form_data[:letters].present? ? form_data[:letters] : nil
            @letters = Erp::Products::PropertiesValue.where(id: letter_ids)

            # get numbers
            number_ids = form_data[:numbers].present? ? form_data[:numbers] : nil
            @numbers = Erp::Products::PropertiesValue.where(id: number_ids)

            # warehouses
            @warehouses = Erp::Warehouses::Warehouse.all

            @product_query = @product_query.where(category_id: category_ids) if category_ids.present?
            # filter by diameters
            if diameter_ids.present?
              if !diameter_ids.kind_of?(Array)
                @product_query = @product_query.where("erp_products_products.cache_properties LIKE '%[\"#{diameter_ids}\",%'")
              else
                diameter_ids = (diameter_ids.reject { |c| c.empty? })
                if !diameter_ids.empty?
                  qs = []
                  diameter_ids.each do |x|
                    qs << "(erp_products_products.cache_properties LIKE '%[\"#{x}\",%')"
                  end
                  @product_query = @product_query.where("(#{qs.join(" OR ")})")
                end
              end
            end
            # filter by letters
            if letter_ids.present?
              if !letter_ids.kind_of?(Array)
                @product_query = @product_query.where("erp_products_products.cache_properties LIKE '%[\"#{letter_ids}\",%'")
              else
                letter_ids = (letter_ids.reject { |c| c.empty? })
                if !letter_ids.empty?
                  qs = []
                  letter_ids.each do |x|
                    qs << "(erp_products_products.cache_properties LIKE '%[\"#{x}\",%')"
                  end
                  @product_query = @product_query.where("(#{qs.join(" OR ")})")
                end
              end
            end
            # filter by numbers
            if number_ids.present?
              if !number_ids.kind_of?(Array)
                @product_query = @product_query.where("erp_products_products.cache_properties LIKE '%[\"#{number_ids}\",%'")
              else
                number_ids = (number_ids.reject { |c| c.empty? })
                if !number_ids.empty?
                  qs = []
                  number_ids.each do |x|
                    qs << "(erp_products_products.cache_properties LIKE '%[\"#{x}\",%')"
                  end
                  @product_query = @product_query.where("(#{qs.join(" OR ")})")
                end
              end
            end
          end

          if category_ids.present? and diameter_ids.present?
            @products = @product_query.limit(20).order("erp_products_categories.name, cache_diameter, code")
          else
            @products = []
          end

          # Default state
          @state = ((params[:form_data].present? and params[:form_data][:default_state].present?) ? params[:form_data][:default_state] : nil)

          @products.each do |p|
            @stock_check.stock_check_details.build(
              product_id: p.id,
              state_id: @state
            )
          end
        end

        private
          # Use callbacks to share common setup or constraints between actions.
          def set_stock_check
            @stock_check = StockCheck.find(params[:id])
          end

          def set_stock_checks
            @stock_checks = StockCheck.where(id: params[:ids])
          end

          # Only allow a trusted parameter "white list" through.
          def stock_check_params
            params.fetch(:stock_check, {}).permit(:code, :adjustment_date, :warehouse_id, :description, :employee_id,
                                            :stock_check_details_attributes => [ :id, :product_id, :stock_check_id, :quantity, :real, :stock, :state_id, :note, :_destroy ])
          end
      end
    end
  end
end
