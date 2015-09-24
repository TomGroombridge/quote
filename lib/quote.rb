require 'csv'
class Quote

	LOAN_TERM = 36
	QUOTE_MINIMUM = 1000
	QUOTE_MAXIMUM = 15000
	INTEREST_COMPOUNDED_PER_YEAR = 12


	def initialize
		@path_to_file = ARGV[0]
		@requested_amount = ARGV[1].to_f
		validate_quote
	end

	def message(text)
		puts text
		text
	end

	def validate_quote
		if correct_amount == true
			if (@increments.include? @requested_amount) == true
				pull_in_lender_info
			else
				message("I'm sorry but you can only apply for a loan in increments of £100.00")
			end
		else
			message("I'm sorry but we only quote for requested amounts between £1000.00 and £15,000.00")
		end
	end

	def correct_amount
		@increments = (QUOTE_MINIMUM..QUOTE_MAXIMUM).step(100).to_a
		if @requested_amount >= QUOTE_MINIMUM && @requested_amount <= QUOTE_MAXIMUM
			true
		else
			false
		end
	end

	def pull_in_lender_info
		@lenders = []
		if File.exists?(@path_to_file)
			CSV.foreach(@path_to_file, headers: true) do |row|
			  @lenders << {:name => row[0], :rate => row[1], :amount => row[2]}
			end
			order_lenders_by_interest(@lenders)
		else
			message("sorry but the path you has specified for the file does not exists")
		end
	end

	def order_lenders_by_interest(lender_list)
		@amount = amount_of_funds(lender_list)
		@ordered_lenders = ordered_lenders(lender_list)
		@lenders_amounts = lenders_amounts(@ordered_lenders)
		check_for_loan(@amount)
	end

	def amount_of_funds(lender_list)
		lender_list.inject(0) {|sum, hash| sum + hash[:amount].to_f}
	end

	def ordered_lenders(lender_list)
		lender_list.sort_by { |hsh| hsh[:rate].to_f }
	end

	def lenders_amounts(ordered_lenders)
		ordered_lenders.map{|x| x[:amount].to_f}
	end

	def enough_funds(amount_available)
		if @requested_amount > amount_available
			false
		else
			true
		end
	end

	def check_for_loan(amount_available)
		if enough_funds(amount_available) == false
			no_loan
		else
			lenders_needed
		end
	end

	def lenders_needed
		@lenders_needed = 0
		@i = 0
		@lenders_amounts.each do |a|
			unless @i >= @requested_amount
				@lenders_needed += 1
				@i += a
			end
		end
		compound_interest
	end

	def compound_interest
		@rate = (@ordered_lenders.first(@lenders_needed).inject(0) {|sum, hash| sum + hash[:rate].to_f} / @lenders_needed).round(2)
		set_principal_payment
	end

	def set_principal_payment
		@principal_payment = (@requested_amount / LOAN_TERM)
		set_repayments
	end

	def set_repayments
		@remaining_principal = @requested_amount
		@total_repayments = 0
		until @remaining_principal <= 0 do
			@interest_per_month = ((@remaining_principal * @rate) / INTEREST_COMPOUNDED_PER_YEAR)
			@total_repayments += (@principal_payment + @interest_per_month)
			@remaining_principal = (@remaining_principal - @principal_payment)
		end
		@monthly_repayments = (@total_repayments / LOAN_TERM).round(2)
		@total_repayments = (@monthly_repayments * LOAN_TERM).round(2)
		send_quote
	end

	def send_quote
		puts " Requested amount: £#{@requested_amount}"
		puts " Rate: #{(@rate.round(2)* 100.0).round(1)}%"
		puts " Monthly repayment: £#{@monthly_repayments.round(2)}"
		puts " Total repayment: £#{@total_repayments.round(2)}"
	end

	def no_loan
		puts "sorry we can't offer you a quote at this time"
	end

end

Quote.new







