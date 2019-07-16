# app\controllers\admin\companies_controller.rb

class CompaniesController < Admin::ApplicationController
  before_action :set_company, only: [:update, :destroy]

  # 一覧
  def index
    filter = ::Companies::Filter.new
    @company_lists = filter.search_companies
  end

  # 登録
  def new
    @company = ::Company.new
    @company_sales_office = @company.company_sales_offices.build
  end

  # 登録確認
  def confirm
    @company = ::Company.new(company_params)
    render :new and return if @company.invalid?
  end

  # 登録処理
  # @note 同期処理
  def create
    Companies::Register.new.insert(company_params)
    render action: :complete
  end

  # 登録完了
  def complete
  end

  # 更新確認
  def update_confirm
    respond_to do |format|
      @company = ::Company.find(company_update_params[:id])
      @company.assign_attributes(company_update_params)

      if @company.valid?
        format.json { render json: company_update_params, status: :ok }
      else
        format.json { fail AsyncRetryValidationError, @company.errors }
      end
    end
  end

  # 更新処理
  # @note 非同期処理
  def update
    respond_to do |format|
      company = Companies::Register.new(@company).update(company_update_params)
      format.json { render json: company, status: :ok }

      if company.errors.blank?
        format.json { render json: maker, status: :ok }
      else
        format.json { fail AsyncRetryValidationError, company.errors }
      end
    end
  end

  # 削除処理
  # @note 非同期処理
  def destroy
    respond_to do |format|
      destroy_company = Companies::Register.new(@company).delete(params)
      if destroy_company.errors.blank?
        format.json { render json: destroy_company, status: :ok }
      else
        format.json { fail AsyncRetryValidationError, destroy_company.errors }
      end
    end
  end

  private

  # パラメータから取得したIDから、会社を取得
  # @note before_actionで指定アクションの前に実行
  def set_company
    @company = ::Company.find(params[:id])
  end

  # 会社パラメータ取得
  def company_params
    params.require(:company).permit(
      :company_name,
      :company_name_kana,
      :updated_at,
      company_sales_offices_attributes: [
        :id,
        :company_id,
        :sales_office_name,
        :sales_office_postal_code,
        :sales_office_address,
        :sales_office_phone_number,
        :updated_at,
        :_destroy
      ]
    )
  end

  # 会社更新パラメータ取得
  def company_update_params
    params.require(:company).permit(
      :id,
      :company_name,
      :company_name_kana,
      :updated_at,
    )
  end

end