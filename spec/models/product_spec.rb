# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Product, type: :model do
  describe 'validations' do
    let(:product) { build(:product) }

    context 'when all attributes are valid' do
      it 'is valid' do
        expect(product).to be_valid
      end
    end

    context 'name validations' do
      it 'requires name' do
        product.name = nil
        expect(product).not_to be_valid
        expect(product.errors[:name]).to include("can't be blank")
      end

      it 'enforces maximum length' do
        product.name = 'a' * 256
        expect(product).not_to be_valid
        expect(product.errors[:name]).to include('is too long (maximum is 255 characters)')
      end
    end

    context 'description validations' do
      it 'requires description' do
        product.description = nil
        expect(product).not_to be_valid
        expect(product.errors[:description]).to include("can't be blank")
      end

      it 'enforces maximum length' do
        product.description = 'a' * 1001
        expect(product).not_to be_valid
        expect(product.errors[:description]).to include('is too long (maximum is 1000 characters)')
      end
    end

    context 'price validations' do
      it 'requires price' do
        product.price = nil
        expect(product).not_to be_valid
        expect(product.errors[:price]).to include("can't be blank")
      end

      it 'must be greater than or equal to 0' do
        product.price = -1
        expect(product).not_to be_valid
        expect(product.errors[:price]).to include('must be greater than or equal to 0')
      end
    end

    context 'unit_size validations' do
      it 'requires unit_size' do
        product.unit_size = nil
        expect(product).not_to be_valid
        expect(product.errors[:unit_size]).to include("can't be blank")
      end

      it 'must be greater than 0' do
        product.unit_size = 0
        expect(product).not_to be_valid
        expect(product.errors[:unit_size]).to include('must be greater than 0')
      end
    end

    context 'stock_count validations' do
      it 'must be greater than or equal to 0' do
        product.stock_count = -1
        expect(product).not_to be_valid
        expect(product.errors[:stock_count]).to include('must be greater than or equal to 0')
      end
    end

    context 'unit_name validations' do
      it 'requires unit_name' do
        product.unit_name = nil
        expect(product).not_to be_valid
        expect(product.errors[:unit_name]).to include("can't be blank")
      end
    end
  end

  describe 'enums' do
    let(:product) { create(:product) }

    it 'defines correct unit_name values' do
      expect(Product.unit_names).to eq({ 'qty' => 0, 'package' => 1, 'kg' => 2, 'gr' => 3 })
    end

    it 'can set and get unit_name' do
      product.unit_name = :kg
      expect(product.unit_name).to eq('kg')
      expect(product.kg?).to be true
    end
  end

  describe 'scopes' do
    let!(:available_product) { create(:product) }
    let!(:obsolete_product) { create(:product, :obsolete) }

    describe '.available' do
      it 'returns only available products' do
        expect(Product.available).to include(available_product)
        expect(Product.available).not_to include(obsolete_product)
      end
    end

    describe '.obsolete' do
      it 'returns only obsolete products' do
        expect(Product.obsolete).to include(obsolete_product)
        expect(Product.obsolete).not_to include(available_product)
      end
    end
  end

  describe '#available_for_quantity?' do
    let(:product) { create(:product, stock_count: 5) }

    context 'when product is available' do
      it 'returns true if requested quantity is available' do
        expect(product.available_for_quantity?(3)).to be true
      end

      it 'returns false if requested quantity exceeds stock' do
        expect(product.available_for_quantity?(6)).to be false
      end

      it 'returns true if requested quantity equals stock' do
        expect(product.available_for_quantity?(5)).to be true
      end
    end

    context 'when product is obsolete' do
      before { product.update(obsolete: true) }

      it 'returns false regardless of stock' do
        expect(product.available_for_quantity?(1)).to be false
      end
    end
  end

  describe '#reserve_stock' do
    let(:product) { create(:product, stock_count: 5) }

    context 'when sufficient stock exists' do
      it 'reduces stock count by specified quantity' do
        expect do
          product.reserve_stock(3)
        end.to change { product.reload.stock_count }.from(5).to(2)
      end

      it 'returns true' do
        expect(product.reserve_stock(3)).to be true
      end
    end

    context 'when insufficient stock exists' do
      it 'does not reduce stock count' do
        expect do
          product.reserve_stock(6)
        end.not_to(change { product.reload.stock_count })
      end

      it 'returns false' do
        expect(product.reserve_stock(6)).to be false
      end
    end

    context 'when product is obsolete' do
      before { product.update(obsolete: true) }

      it 'does not reduce stock count' do
        expect do
          product.reserve_stock(1)
        end.not_to(change { product.reload.stock_count })
      end

      it 'returns false' do
        expect(product.reserve_stock(1)).to be false
      end
    end

    context 'with concurrent access' do
      it 'handles race conditions using optimistic locking' do
        product_1 = Product.find(product.id)
        product_2 = Product.find(product.id)

        product_1.reserve_stock(3)
        expect(product_2.reserve_stock(3)).to be false
      end
    end
  end

  describe 'optimistic locking' do
    let(:product) { create(:product, stock_count: 10) }

    it 'prevents concurrent stock updates' do
      product_1 = Product.find(product.id)
      product_2 = Product.find(product.id)

      product_1.update!(stock_count: 8)

      expect do
        product_2.update!(stock_count: 6)
      end.to raise_error(ActiveRecord::StaleObjectError)
    end
  end

  describe 'unit types' do
    it 'supports different unit types' do
      expect(Product.unit_names).to include('qty' => 0, 'package' => 1, 'kg' => 2, 'gr' => 3)
    end

    it 'allows setting different unit types' do
      product = create(:product, unit_name: :kg, unit_size: 0.5)
      expect(product.unit_name).to eq('kg')
      expect(product.unit_size).to eq(0.5)
    end

    it 'does not allow setting invalid unit types' do
      product = build(:product)
      expect do
        product.unit_name = :invalid
      end.to raise_error(ArgumentError, '\'invalid\' is not a valid unit_name')
    end
  end
end
