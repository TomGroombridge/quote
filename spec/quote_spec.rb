require './lib/quote'

RSpec.describe 'csv import' do
	let(:quote) {Quote.new}

	context 'quote' do
		before(:each)do
			@lender_list = [{:name=>"Jane", :rate=>"0.069", :amount=>"480"},
													{:name=>"Fred", :rate=>"0.071", :amount=>"520"},
													{:name=>"Bob", :rate=>"0.075", :amount=>"640"},
													{:name=>"Mary", :rate=>"0.104", :amount=>"170"},
													{:name=>"Angela", :rate=>"0.071", :amount=>"60"},
													{:name=>"Dave", :rate=>"0.074", :amount=>"140"},
													{:name=>"John", :rate=>"0.081", :amount=>"320"}
												]
		end

		it "should return a error message if the amount requested is under £1000" do
			stub_const("ARGV", ['lender_file', 999])
			expect(quote.correct_amount).to be false
			expect(quote.validate_quote).to eq "I'm sorry but we only quote for requested amounts between £1000.00 and £15,000.00"
		end

		it "should return a error message if the amount requested is over £15000" do
			stub_const("ARGV", ['lender_file', 15001])
			expect(quote.correct_amount).to be false
			expect(quote.validate_quote).to eq "I'm sorry but we only quote for requested amounts between £1000.00 and £15,000.00"
		end

		it "should return a error message if the amount requested is not incremented by £100" do
			stub_const("ARGV", ['lender_file', 1001])
			expect(quote.correct_amount).to be true
			expect(quote.validate_quote).to eq "I'm sorry but you can only apply for a loan in increments of £100.00"
		end

		it "should return a error message if the path to the csv file does not exist" do
			stub_const("ARGV", ['lender_file', 1000])
			expect(quote.correct_amount).to be true
			expect(quote.validate_quote).to eq "sorry but the path you has specified for the file does not exists"
		end

		it "should return a error message if the file format is not '.csv' " do

		end

		it "should return error message if the requested amount exceeds the amount available from lenders" do
			stub_const("ARGV", ['lender_file', 1000])
			amount_available = 999
			expect(quote.enough_funds(amount_available)).to be false
		end

		it "should return the interest rate of 7% for a £1000 quote with this csv" do

		end

		it "should be able to work out the total amount of funds available" do
			expect(quote.amount_of_funds(@lender_list)).to eq 2330.0
		end

		it "should be able to sort the lender list by rate" do
			expect(quote.ordered_lenders(@lender_list)).to eq([{:name=>"Jane", :rate=>"0.069", :amount=>"480"},
																													{:name=>"Fred", :rate=>"0.071", :amount=>"520"},
																													{:name=>"Angela", :rate=>"0.071", :amount=>"60"},
																													{:name=>"Dave", :rate=>"0.074", :amount=>"140"},
																													{:name=>"Bob", :rate=>"0.075", :amount=>"640"},
																													{:name=>"John", :rate=>"0.081", :amount=>"320"},
																													{:name=>"Mary", :rate=>"0.104", :amount=>"170"}])
		end


		it "should be able to create a list of all the lenders amount" do
			ordered_lenders = quote.ordered_lenders(@lender_list)
			expect(quote.lenders_amounts(ordered_lenders)).to eq([480.0, 520.0, 60.0, 140.0, 640.0, 320.0, 170.0])
		end
	end


end