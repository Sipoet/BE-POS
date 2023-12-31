require 'rails_helper'

RSpec.describe RefreshActivePromotionJob, type: :job do

  describe 'promotion' do
    it 'should active when within range' do
      promotions =[
        Promotion.create!(iddiskon: 'promotion1', stsact: false, tgldari: DateTime.now, tglsampai: 1.month.from_now),
        Promotion.create!(iddiskon: 'promotion2', stsact: false, tgldari: 1.month.ago, tglsampai: 1.minute.from_now),
        Promotion.create!(iddiskon: 'promotion3', stsact: true, tgldari: 1.hour.ago, tglsampai: 1.day.from_now)
      ]
      expect{
        RefreshActivePromotionJob.new.perform
      }.not_to raise_error
      promotions.each.with_index(1) do |promotion, index|
        promotion.reload
        expect(promotion.stsact).to be_truthy,"promotion #{index} should be active"
      end
    end
    it 'should inactive when expired' do
      promotions =[
        Promotion.create!(iddiskon: 'promotion1', stsact: true, tgldari: 1.year.ago, tglsampai: 1.day.ago),
        Promotion.create!(iddiskon: 'promotion2', stsact: true, tgldari: 1.month.ago, tglsampai: 1.minute.ago),
        Promotion.create!(iddiskon: 'promotion3', stsact: true, tgldari: 1.day.ago, tglsampai: 1.hour.ago)
      ]
      expect{
        RefreshActivePromotionJob.new.perform
      }.not_to raise_error
      promotions.each.with_index(1) do |promotion, index|
        promotion.reload
        expect(promotion.stsact).to be_falsy,"promotion #{index} should not be active"
      end
    end
  end

  describe 'item promotion' do
    let(:item){create(:item)}
    let(:discount){create(:discount,item: nil,brand: item.brand, supplier: nil, item_type: nil)}
    before :each do
      RefreshPromotionJob.new.perform(discount.id)
    end
    it 'should added new item meet requirement' do
      item2 = create(:item, brand: item.brand)
      query = ItemPromotion.where(kodeitem: item2.kodeitem)
      query_item_discount = ItemPromotion.where("iddiskon ilike '%#{discount.code}%'")
      expect(query.count).to eq(0)
      expect(query_item_discount.count).to eq(1)
      expect{
        RefreshActivePromotionJob.new.perform
      }.not_to raise_error
      expect(query.count).to eq(1)
      expect(query_item_discount.count).to eq(2)
      item_promotion = query.first
      expect(item_promotion.iddiskon).to be_include(discount.code)
    end

    it 'should not added item not meet requirement' do
      item2 = create(:item, brand: create(:brand))
      query = ItemPromotion.where(kodeitem: item2.kodeitem)
      query_item_discount = ItemPromotion.where("iddiskon ilike '%#{discount.code}%'")
      expect(query.count).to eq(0)
      expect(query_item_discount.count).to eq(1)
      expect{
        RefreshActivePromotionJob.new.perform
      }.not_to raise_error
      expect(query.count).to eq(0)
      expect(query_item_discount.count).to eq(1)
    end

    it 'should choose smallest discount if meet requirement multiple active promotion' do
      discount2 = create(:discount,item: nil,brand: nil, item_type: nil)
      item2 = create(:item, supplier: discount2.supplier)
      query = ItemPromotion.where(kodeitem: item2.kodeitem)
      expect(query.count).to eq(0)
      expect{
        RefreshActivePromotionJob.new.perform
      }.not_to raise_error
      expect(query.count).to eq(1)
      item_promotion = query.first
      expect(item_promotion.iddiskon).to be_include(discount2.code)
      expect(item_promotion.iddiskon).not_to be_include(discount.code)
    end
  end

end
