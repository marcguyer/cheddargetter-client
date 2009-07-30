require 'rubygems'
require 'httparty'
require 'libxml'

module CheddarGetter
	
	class Request 
		include HTTParty
		headers 'User-Agent' => 'CheddarGetter Client Ruby'
		format :plain
		
		def initialize(url, username, password, productCode = nil)
			self.class.base_uri url
			self.class.basic_auth username, password
			@productCode = productCode
		end
		
		def productCode=(productCode)
			@productCode = productCode
		end
		
		def plans(filters = nil)
			return Response.new(request('/plans/get', filters))
		end
		
		def plan(code, id = nil)
			raise ArgumentError, 'code|id is required' if code.blank? || id.blank?
			return Response.new(request('/plans/get/' + (id!=nil ? id : code)))
		end
		
		def newPlan(data)
			return Response.new(request('/plans/new', data))
		end
		
		def editPlan(code, id = nil, data)
			raise ArgumentError, 'code|id is required' if code.blank? || id.blank?
			return Response.new(request('/plans/edit/' + (id ? 'id/' + id : 'code/' + code), data))
		end
		
		def deletePlan(code, id)
			raise ArgumentError, 'code|id is required' if code.blank? || id.blank?
			return Response.new(request('/plans/delete/' + (id ? 'id/' + id : 'code/' + code)))
		end
		
		def customers(filters = nil)
			return Response.new(request('/customers/get', filters))
		end
		
		def customer(code, id = nil)
			raise ArgumentError, 'code|id is required' if code.blank? || id.blank?
			return Response.new(request('/customers/get/' + (id!=nil ? id : code)))
		end
		
		def newCustomer(data)
			return Response.new(request('/customers/new', data))
		end
		
		def editCustomer(code, id = nil, data)
			raise ArgumentError, 'code|id is required' if code.blank? || id.blank?
			return Response.new(request('/customers/edit/' + (id!=nil ? id : code), data))
		end
		
		def deleteCustomer(code, id = nil)
			raise ArgumentError, 'code|id is required' if code.blank? || id.blank?
			return Response.new(request('/customers/delete/' + (id!=nil ? id : code), data)) 
		end
		
		def editSubscription(code, id = nil, data)
			raise ArgumentError, 'code|id is required' if code.blank? || id.blank?
			return Response.new(request('/customers/edit-subscription/' + (id!=nil ? id : code), data))
		end
		
		def cancelSubscription(code, id = nil)
			raise ArgumentError, 'code|id is required' if code.blank? || id.blank?
			return Response.new(request('/customers/cancel/' + (id!=nil ? id : code)))
		end
		
		def addItemQuantity(code, id = nil, data)
			raise ArgumentError, 'code|id is required' if code.blank? || id.blank?
			return Response.new(request('/customers/add-item-quantity/' + (id!=nil ? id : code), data))
		end
		
		def removeItemQuantity(code, id = nil, data)
			raise ArgumentError, 'code|id is required' if code.blank? || id.blank?
			return Response.new(request('/customers/remove-item-quantity/' + (id!=nil ? id : code), data))
		end
		
		def setItemQuantity(code, id = nil, data)
			raise ArgumentError, 'code|id is required' if code.blank? || id.blank?
			return Response.new(request('/customers/set-item-quantity/' + (id!=nil ? id : code), data))
		end
		
		def request(path, args = nil)
			path = '/xml/' + path + (@productCode!=nil ? '/productCode/' + @productCode : '')
			# convert multiple adjacent slashes to single slashes
			path = path.gsub(/(\w)\/+/, '\1/')
			
			if (args != nil)
				return Request.post(path, :query => args).to_s
			else
				return Request.get(path).to_s
			end
		end
		
	end
	
	class Response
		include LibXML
		
		def initialize(xml)
			@document = XML::Document.string(xml)
			@responseType = @document.root.name
		end
		
		def to_s
			return @document.to_s
		end
		
		def to_a
			if (@array != nil)
				return @array
			end
			
			if (@responseType == 'error') 
				return [
					{
						'code' => @document.root.attributes.get_attribute('code').value,
						'message' => @document.root.first.content
					}
				]
			end
			@array = _toArray(@document.root.children);
			return @array;
			
		end
		
		def plan(code = nil)
			raise ArgumentException 'Can\'t get a plan from a response that isn\'t of type \'plans\'' if @responseType != 'plans'
			raise 'This response contains more than one plan so you need to provide the code for the plan you wish to get' if code.blank? && @document.root.children.length > 1
			
			if code.blank?
				return to_a.first
			end
			return to_a[code]
		end
		
		def planItem(code = nil, itemCode = nil)
			plan = plan(code)
			raise ArgumentException 'This plan contains more than one item so you need to provide the code for the item you wish to get' if itemCode.blank? && plan['items'].length > 1
			
			if itemCode.blank?
				return plan['items'].first
			end
			return plan['items'][itemCode]
		end
		
		def customer(code = nil)
			raise ArgumentException 'Can\'t get a customer from a response that isn\'t of type \'customers\'' if @responseType != 'customers'
			raise ArgumentException 'This response contains more than one customer so you need to provide the code for the customer you wish to get' if code.blank? && @document.root.children.length > 1
			
			if code.blank?
				return to_a.first
			end
			return to_a[code]
		end
		
		def customerSubscription(code = nil)
			customer = customer(code)
			return customer['subscriptions'].first
		end
		
		def customerPlan(code = nil)
			subscription = customerSubscription(code)
			return subscription['plans'].first
		end
		
		def customerInvoice(code = nil)
			subscription = customerSubscription(code)
			return subscription['invoices'].first
		end
		
		def customerItemQuantity(code = nil, itemCode = nil)
			subscription = customerSubscription(code)
			raise ArgumentException 'This customer\'s subscription contains more than one item so you need to provide the code for the item you wish to get' if itemCode.blank? && subscription['items'].length > 1
			plan = customerPlan(code)
			if !itemCode.blank?
				return {
					'item' => plan['items'][itemCode],
					'quantity' => subscription['items'][itemCode]
				}
			else
				return {
					'item' => plan['items'].first,
					'quantity' => subscription['items'].first
				}
			end
		end
		
		private
		
		def _toArray(nodes) 
			array = Hash.new(0)
			nodes.each { |node|
				if (!node.element?) 
					next
				end
				
				if (node.attributes?) #deep
					if (!node.attributes['code'].blank?)   
						key = node.attributes['code']
						array[key] = Hash.new()
						if (!node.attributes['id'].blank?)
							array[key] = {
								'id' => node.attributes['id']
							}
						end
						array[key]['code'] = key
					else
						key = node.attributes['id']
						array[key] = Hash.new(0)
					end
					array[key] = array[key].merge(_toArray(node.children))
				else
					if (node.children.length > 1) # sub array
						array[node.name] = _toArray(node.children)
					else
						array[node.name] = node.content
					end
				end
			}
			return array
		end
		
	end
	
end