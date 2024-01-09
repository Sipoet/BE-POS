require 'rails_helper'

RSpec.describe RefreshPromotionJob, type: :job do

  describe 'brand discount' do
    let(:discount){create(:discount, supplier: nil, item_type: nil, item: nil)}
    it 'should be included if same with item' do
      item = create(:item, brand: discount.brand)
      item2 = create(:item, brand: create(:brand))
      expect(item.brand).not_to eq(item2.brand)
      expect{
        RefreshPromotionJob.new.perform(discount.id)
      }.not_to raise_error
      query = Ipos::ItemPromotion.where(kodeitem: item.kodeitem)
      expect(query.count).to eq(1)
      expect(query.first.iddiskon).to be_include(discount.code)
      expect(Ipos::ItemPromotion.where(kodeitem: item2.kodeitem).count).to eq(0)
    end
  end

  describe 'supplier discount' do
    let(:discount){create(:discount, item_type: nil, brand: nil, item: nil)}
    it 'should be included if same with item' do
      item = create(:item, supplier: discount.supplier)
      item2 = create(:item, supplier: create(:supplier))
      expect(item.supplier).not_to eq(item2.supplier)
      expect{
        RefreshPromotionJob.new.perform(discount.id)
      }.not_to raise_error
      query = Ipos::ItemPromotion.where(kodeitem: item.kodeitem)
      expect(query.count).to eq(1)
      expect(query.first.iddiskon).to be_include(discount.code)
      expect(Ipos::ItemPromotion.where(kodeitem: item2.kodeitem).count).to eq(0)
    end
  end

  describe 'item type discount' do
    let(:discount){create(:discount, supplier: nil, brand: nil, item: nil)}
    it 'should be included if same with item' do
      item = create(:item, item_type: discount.item_type)
      item2 = create(:item, item_type: create(:item_type))
      expect(item.item_type).not_to eq(item2.item_type)
      expect{
        RefreshPromotionJob.new.perform(discount.id)
      }.not_to raise_error
      query = Ipos::ItemPromotion.where(kodeitem: item.kodeitem)
      expect(query.count).to eq(1)
      expect(query.first.iddiskon).to be_include(discount.code)
      expect(Ipos::ItemPromotion.where(kodeitem: item2.kodeitem).count).to eq(0)
    end
  end

  it 'discount with filter item should be included' do
    item = create(:item)
    discount=create(:discount, supplier: nil, brand: nil, item_type: nil, item: item)
    item2 = create(:item)
    expect{
      RefreshPromotionJob.new.perform(discount.id)
    }.not_to raise_error
    query = Ipos::ItemPromotion.where(kodeitem: item.kodeitem)
    expect(query.count).to eq(1)
    expect(query.first.iddiskon).to be_include(discount.code)
    expect(Ipos::ItemPromotion.where(kodeitem: item2.kodeitem).count).to eq(0)
  end

end
