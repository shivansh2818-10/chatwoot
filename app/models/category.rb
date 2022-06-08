# == Schema Information
#
# Table name: categories
#
#  id                        :bigint           not null, primary key
#  description               :text
#  locale                    :string           default("en")
#  name                      :string
#  position                  :integer
#  slug                      :string           default("Category"), not null
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#  account_id                :integer          not null
#  associated_category_id    :integer
#  associated_category_id_id :bigint
#  parent_category_id        :integer
#  parent_category_id_id     :bigint
#  portal_id                 :integer          not null
#
# Indexes
#
#  index_categories_on_associated_category_id_id      (associated_category_id_id)
#  index_categories_on_locale                         (locale)
#  index_categories_on_locale_and_account_id          (locale,account_id)
#  index_categories_on_parent_category_id_id          (parent_category_id_id)
#  index_categories_on_slug_and_locale_and_portal_id  (slug,locale,portal_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (associated_category_id_id => categories.id)
#  fk_rails_...  (parent_category_id_id => categories.id)
#
class Category < ApplicationRecord
  belongs_to :account
  belongs_to :portal
  has_many :folders, dependent: :destroy_async
  has_many :articles, dependent: :nullify

  before_validation :ensure_account_id
  validates :account_id, presence: true
  validates :name, presence: true
  validates :locale, uniqueness: { scope: %i[slug portal_id],
                                   message: 'should be unique in the category and portal' }

  scope :search_by_locale, ->(locale) { where(locale: locale) if locale.present? }

  def self.search(params)
    search_by_locale(params[:locale]).page(current_page(params)).order(position: :asc)
  end

  def self.current_page(params)
    params[:page] || 1
  end

  private

  def ensure_account_id
    self.account_id = portal&.account_id
  end
end
