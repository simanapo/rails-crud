# app\models\company_sales_office.rb

class CompanySalesOffice < ApplicationRecord
  # 論理削除使用
  acts_as_paranoid

  ##
  # リレーション
  ##
  belongs_to :company, optional: true

  ##
  # バリデーション
  ##
  # 会社ID
  validates :company_id,
    presence: true,
    on: :update

  # 営業所名
  validates :sales_office_name,
    presence: true,
    length: { maximum: 150 }

  # 郵便番号
  validates :sales_office_postal_code,
    presence: true,
    format: { with: /\A[0-9\-]+\z/ },
    length: { maximum: 8 },
    reduce: true

  # 住所
  validates :sales_office_address,
    presence: true,
    length: { maximum: 500 }

  # 電話番号
  validates :sales_office_phone_number,
    presence: true,
    format: { with: /\A[0-9\-]+\z/ },
    length: { maximum: 13 },
    reduce: true

  ##
  # scopes
  ##
  # 会社（内部）
  scope :with_inner_company, -> { joins(:company).eager_load(:company) }

  # 会社（外部）
  scope :with_company, -> { eager_load(:company) }

  # 更新済みチェック
  # @param [String] updated_at 更新前更新日時
  # @param [CompanySalesOffice] sales_office 会社営業所
  # @return [Boolean] 更新されている : true 更新されていない : false
  def self.already_updated?(updated_at, sales_office)
    sales_office_updated_at = sales_office&.updated_at&.to_s || ''
    updated_at != sales_office_updated_at
  end

  # 削除済みチェック
  # @param [CompanySalesOffice] sales_office 会社営業所
  # @return [Boolean] 削除されている : true 削除されていない : false
  def self.already_deleted?(sales_office)
    CompanySalesOffice.exists?(id: sales_office.id, old_flg: CompanySalesOffice.old_flgs[:is_old])
  end

end