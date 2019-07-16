# app\models\company.rb

class Company < ApplicationRecord
  # 論理削除使用
  acts_as_paranoid

  ##
  # リレーション
  ##
  has_many :company_sales_offices
  accepts_nested_attributes_for :company_sales_offices, allow_destroy: true

  ##
  # バリデーション
  ##
  validates :company_name,
    presence: true,
    length: { maximum: 150 }

  validates :company_name_kana,
    presence: true,
    length: { allow_blank: true, maximum: 150 },
    format: { allow_blank: true, with: /\A(?:\p{Katakana}|[ー－])+\z/, message: :invalid_em_kana }

  validates :old_flg,
    presence: true,
    inclusion: { in: Company.old_flgs.keys }

  ##
  # scopes
  ##
  # 会社営業所(内部)
  scope :with_inner_company_sales_offices, -> { joins(:company_sales_offices).eager_load(:company_sales_offices) }

  # 会社営業所(外部)
  scope :with_company_sales_offices, -> { eager_load(:company_sales_offices) }

  # 会社重複チェック
  # @param [Company] company 会社
  # @return [Boolean] 重複している : true 重複していない : false
  # @note 更新時は、「更新対象会社ID以外」の条件が追加される
  def self.name_duplicated?(company)
    query = self.company_name_is(company.company_name)
    query = query&.id_is_not(company.id)&.is_not_old if company.id.present?
    query.present?
  end

  # 更新済みチェック
  # @param [String] updated_at 更新前更新日時
  # @param [Company] company 会社
  # @return [Boolean] 更新されている : true 更新されていない : false
  def self.already_updated?(updated_at, company)
    company_updated_at = company&.updated_at&.to_s || ''
    updated_at != company_updated_at
  end

  # 削除済みチェック
  # @param [Company] company 会社
  # @return [Boolean] 削除されている : true 削除されていない : false
  def self.already_deleted?(company)
    Company.exists?(id: company.id, old_flg: Company.old_flgs[:is_old])
  end

end
