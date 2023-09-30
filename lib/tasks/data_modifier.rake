namespace :data_modifier do
  BRAND_DISCOUNTS = {
    'Y.O.U'=> 10,
    'BARENBLISS'=> 10,
    'LOIS'=> 10,
    'CARDINAL'=> 10
  }.freeze
  task create_promo: :environment do
    promo_desc = 'sept2023'
    start_date = Date.new(2023,9,1).beginning_of_day
    end_date = Date.new(2023,9,30).end_of_day
    codes = Promotion.where(tgldari: start_date)
                      .pluck(:iddiskon)
    # ItemPromotion.where(iddiskon: codes).destroy_all
    # Promotion.where(tgldari: start_date).delete_all
    ItemType.all.order(jenis: :asc).each do |item_type|
      next if ['406-PPK','715-OBR'].include?(item_type.jenis)
      item_query = Item.where(jenis: item_type.jenis)
                        .order(merek: :asc,kodeitem: :asc)
                        .limit(1000)
      page = 1
      discount = get_discount_by_item_type(item_type.jenis)
      loop do
        items = item_query.page(page).per(200)
        break unless items.exists?
        promo_name = "#{page}#{item_type.jenis[4..-1]}#{promo_desc}"
        promotion = create_promotion!(promo_name: promo_name, start_date: start_date, end_date: end_date)
        puts "promo #{promotion.iddiskon}"
        items.group_by(&:merek)
            .each do |merek, items|
          diskon1 = get_discount_by_brand(merek) || discount
          item_docs = items.map do |item|
            puts "item #{item.kodeitem} diskon #{diskon1}"
            {
              iddiskon: promotion.iddiskon,
              kodeitem: item.kodeitem,
              satuan: item.satuan,
              opsidiskon: 1,
              diskon1: diskon1,
              diskon2: 0,
              diskon3: 0,
              diskon4: 0,
            }
          end
          ItemPromotion.insert_all(item_docs)
        end
        page += 1
      end
    end
  end

  def create_promotion!(promo_name:, start_date:, end_date:)
    promotion = Promotion.find_or_initialize_by(iddiskon: promo_name)
    promotion.tgldari = start_date
    promotion.tglsampai = end_date
    promotion.stsact = true
    promotion.jamdari = promotion.tgldari
    promotion.jamsampai = promotion.tglsampai
    promotion.prioritas = 1
    promotion.pot1 = 0
    promotion.pot2 = 0
    promotion.pot3 = 0
    promotion.pot4 = 0
    promotion.tipeper = '1'
    promotion.save!
    promotion
  end

  task create_promo2: :environment do
    promo_desc = 'septOkt2023'
    start_date = Date.new(2023,9,1).beginning_of_day
    end_date = DateTime.new(2023,10,31,23,59,59)
    items = Item.where(tanggal_add: Date.new(2023,9,1)..)
    grouped = items.group_by(&:jenis)
    page = 20
    grouped.each do |item_type_str, grouped_items|
      next if ['406-PPK','715-OBR'].include?(item_type_str)
      discount = get_discount_by_item_type(item_type_str)
      promo_name = "#{page}#{item_type_str[4..-1]}#{promo_desc}"
      promotion = create_promotion!(promo_name: promo_name, start_date: start_date, end_date: end_date)
      grouped_items.group_by(&:merek)
            .each do |merek, items|
          diskon1 = get_discount_by_brand(merek) || discount
          item_docs = items.map do |item|
            puts "item #{item.kodeitem} diskon #{diskon1}"
            {
              iddiskon: promotion.iddiskon,
              kodeitem: item.kodeitem,
              satuan: item.satuan,
              opsidiskon: 1,
              diskon1: diskon1,
              diskon2: 0,
              diskon3: 0,
              diskon4: 0,
            }
          end
          ItemPromotion.insert_all(item_docs)
        end
    end
  end

  def get_discount_by_item_type(type)
    if ['3','4'].include?(type[0])
      20
    elsif type == '602-COS'
      5
    else
      10
    end
  end

  def get_discount_by_brand(brand_name)
    BRAND_DISCOUNTS[brand_name]
  end
end
