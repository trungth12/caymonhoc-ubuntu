﻿require 'resque'
require 'sinatra'
require 'tire'
require 'yajl/json_gem'
require 'csv'
require 'savon'
require 'json'




disable = '#FF0000'
mdanghoc = '#0033FF'
class Archive
  @queue = :logging

  def self.perform(ip, time, id)	
    puts "From queue " + @queue.to_s 
	
	Tire.index 'logs3' do      
      create
      store :ip => ip,   :time => time, :msv => id
      refresh
    end
	
  end
end
before do
    content_type 'application/json'
end
get '/check/:id' do |id|
	msv = id.strip
	client = Savon.client("http://10.1.0.237:8082/Services.asmx?wsdl")
	response = client.request(:thong_tin_sinh_vien) do		
		soap.body = {:masinhvien => msv}
	end
	res_hash = response.body.to_hash
	
	ls = res_hash[:thong_tin_sinh_vien_response][:thong_tin_sinh_vien_result][:diffgram][:document_element];
	if (ls != nil) then 	
		ls = ls[:thong_tin_sinh_vien]			
		tinchi = ls[:dao_tao_theo_tin_chi]		
=begin
		encoded_string = ls[:anh_sinh_vien].strip
		File.open("D:\\anhsinhvien.jpg", "wb") do |file|
	    	file.write(Base64.decode64(encoded_string))
		end
=end
		if (tinchi == false)  then
			return '{"error":"nienche"}'
		else
			temp = {}			
			temp["masinhvien"] = ls[:ma_sinh_vien].strip if ls[:ma_sinh_vien]
			temp["hovaten"] = ls[:ho_dem].strip + ' ' + ls[:ten].strip if ls[:ho_dem] and ls[:ten]
			temp["gioitinh"] = ls[:gioi_tinh].strip if ls[:gioi_tinh]
			temp["malop"] = ls[:ma_lop].strip if ls[:ma_lop]
			temp["tennganh"] = ls[:ten_nganh].strip if ls[:ten_nganh]
			temp["tenhedaotao"] = ls[:ten_he_dao_tao].strip	if ls[:ten_he_dao_tao]
			temp["daotao"] = ls[:dao_tao].strip if ls[:dao_tao]
			temp["tinhtrang"] = ls[:tinh_trang].strip if ls[:tinh_trang]
			temp["khoahoc"] = ls[:ten_khoa_hoc].strip if ls[:ten_khoa_hoc]
			temp.to_json
		end
		
	else return '{"error":"khongtontai"}' end
end
get '/:ip/:id' do |ip,id|	
	nodes = []
links = []
tags = {}
sbjs = {}
deps = {}
courses = {}
names = {}
groups = {}
colors = {}
prev = {}
status = {}
diem = {}
replace = {}
courses2 = {}
danghoc = {}
mas = 1


	msv = id.strip;
	Resque.enqueue(Archive, ip, Time.now.to_s, msv)
	i = 0;
	client = Savon.client("http://10.1.0.237:8082/Services.asmx?wsdl");
	response = client.request(:mon_sinh_vien_da_qua) do
		soap.body = {:masinhvien => msv };
	end;
	response2 = client.request(:mon_sinh_vien_no) do
		soap.body = {:masinhvien => msv };
	end;
	response_courses = client.request(:khung_chuong_trinh) do
		soap.body = {:masinhvien => msv };
	end;
	response_replace = client.request(:mon_thay_the) do
		soap.body = {:masinhvien => msv};
	end;
	response_dk = client.request(:dieu_kien_truoc_sau) do
		soap.body = {:masinhvien => msv };
	end;
	response_danghoc = client.request(:mon_hoc_trong_ky) do
		soap.body = {:masinhvien => msv};
	end;

	res_hash = response.body.to_hash;
	res_hash2 = response2.body.to_hash;
	res_hash_courses = response_courses.body.to_hash;
	res_hash_replace = response_replace.body.to_hash;
	res_hash_dk = response_dk.body.to_hash;
	res_hash_danghoc = response_danghoc.to_hash;

	ls = res_hash[:mon_sinh_vien_da_qua_response][:mon_sinh_vien_da_qua_result][:diffgram][:document_element];
	if (ls ) then 
		temp = ls[:mon_sinh_vien_da_qua];
		if (temp.is_a?(Hash)) then 
			ls = Array.new
			ls.push(temp);
		else (temp.is_a?(Array))
			ls = temp;
		end
	else 
		puts "Da qua het";
		#return '{"error":"error1"} '
	end
	ls2 = res_hash2[:mon_sinh_vien_no_response][:mon_sinh_vien_no_result][:diffgram][:document_element];
	if (ls2) then 
		temp = ls2[:mon_sinh_vien_no];
		if (temp.is_a?(Hash)) then 
			ls2 = Array.new
			ls2.push(temp)
		else (temp.is_a?(Array))
			ls2 = temp
		end
	else 
		puts "Khong co mon no";
		#return '{"error":"error2"}' 
	end
	ls_danghoc = res_hash_danghoc[:mon_hoc_trong_ky_response][:mon_hoc_trong_ky_result][:diffgram][:document_element];
	if (ls_danghoc) then
		temp = ls_danghoc[:mon_hoc_trong_ky];
		if (temp.is_a?(Hash)) then 
			ls_danghoc = Array.new;
			ls_danghoc.push(temp);
		else (temp.is_a?(Array))
			ls_danghoc = temp;
		end
	else
		puts 'Thoi hoc'
	end

	ls_courses = res_hash_courses[:khung_chuong_trinh_response][:khung_chuong_trinh_result][:diffgram][:document_element];	
	if (ls_courses) then 
		temp = ls_courses[:khung_chuong_trinh];
		
		if (temp.is_a?(Hash)) then 
			ls_courses = Array.new;
			ls_courses.push(temp);
		else (temp.is_a?(Array))
			ls_courses = temp;
		end
	else 
		puts "error3";
		return '{"error":"error3"}' 
	end
	ls_replace = res_hash_replace[:mon_thay_the_response][:mon_thay_the_result][:diffgram][:document_element];
	if (ls_replace) then 		
		temp = ls_replace[:mon_thay_the]	;	
		if (temp.is_a?(Hash)) then 
			ls_replace = Array.new
			ls_replace.push(temp);
		else (temp.is_a?(Array))
			ls_replace = temp;
		end
		
	else
		puts "Khong co mon thay the"
	end
	ls_dk = res_hash_dk[:dieu_kien_truoc_sau_response][:dieu_kien_truoc_sau_result][:diffgram][:document_element];
	if (ls_dk) then 
		temp = ls_dk[:dieu_kien_truoc_sau];
		if (temp.is_a?(Hash)) then 
			ls_dk = Array.new
			ls_dk.push(temp)
		else (temp.is_a?(Array))
			ls_dk = temp;
		end
	else 
		puts "Khong co dieu kien truoc sau";		
	end
	if (ls_danghoc) then
		ls_danghoc.each do |item|
			temp = item[:ma_mon_hoc].strip
			danghoc[temp] = 1
		end
	end
	ls_courses.each do |item|
		temp = item[:ma_mon_hoc].strip
		sbjs[temp] = 0		
		
		status[temp] = {}
		status[temp]['makhoi'] = item[:ma_khoi_kien_thuc].strip
		status[temp]['khoikienthuc'] = item[:ten_khoi_kien_thuc].strip
		if (danghoc[temp] == 1) then status[temp]['tinhtrang'] = mdanghoc		
		else status[temp]['tinhtrang'] = disable		end
		status[temp]['ten'] = item[:ten_mon_hoc].strip
		status[temp]['khoiluong'] = item[:tong_so].strip	
		status[temp]['nhom'] = 1
		if (item[:tu_chon]) then 
			if (item[:so_mon_phai_chon]) then 
				status[temp]['somontuchon'] = item[:so_mon_phai_chon].strip + '/' + item[:tong_so_mon_tu_chon].strip
				if (item[:ten_nhom] ) then 
					status[temp]['tennhom'] = item[:ten_nhom].strip
				else
					status[temp]['tennhom'] = ''
				end
			else
				status[temp]['somontuchon'] = ''
				status[temp]['tennhom'] = ''
			end

			status[temp]['tuchon'] = 1 
		else status[temp]['tuchon'] = 0 
		end
	end
	outside = '#FF9900'
	outside_fail = '#FF99FF'
	if (ls_replace) then 				
		ls_replace.each do |item|								
			mon1 = item[:ma_mon_hoc1].strip			
			mon2 = item[:ma_mon_hoc2].strip
			

			if (status[mon1] == nil) then status[mon1] = {} end
			status[mon1]['thaythe'] = mon2			
			replace[mon2] = mon1
			if (danghoc[mon2] == 1) then 
				status[mon1]['tinhtrang'] = mdanghoc
			end
		end
	end
	if (ls_dk) then 
		ls_dk.each do |item| 		
			mon1 = item[:ma_mon_hoc1].strip
			mon2 = item[:ma_mon_hoc2].strip

			if (replace[mon1]) then mon1 = replace[mon1] end
			if (replace[mon2]) then mon2 = replace[mon2] end


			if (!deps[mon1]) then deps[mon1] = Array.new end
			if (!prev[mon2]) then prev[mon2] = Array.new end
			deps[mon1].push(mon2)
			prev[mon2].push(mon1)

			if (sbjs[mon1]) then
				sbjs[mon1] = sbjs[mon1] + 1
			else
				puts "error subject " + mon1
				sbjs[mon1] = 1
			end

			if (sbjs[mon2]) then
				sbjs[mon2] = sbjs[mon2] + 1		
			else
				puts "error subject2: " + mon2
				sbjs[mon2] = 1
			end

			
		end
		ls_dk.each do |item| 
			mon1 = item[:ma_mon_hoc1].strip
			mon2 = item[:ma_mon_hoc2].strip		
			mas = [ro(status, deps, mon1, 1),mas].max		
		end
	end


	pass = '#006666'	
	fail = '#CCCC00'
	if (ls ) then
		ls.each do |item|
			temp = item[:ma_mon_hoc].strip
			diem =  item[:diem_max].strip
			if (replace[temp]) then temp = replace[temp] end

			if (status[temp] ) then 
				status[temp]['tinhtrang'] = pass			
				status[temp]['diem'] = diem				
			else 
				if (replace[temp] == nil) then 
					status[temp] = {}
					status[temp]['tinhtrang'] = pass			
					status[temp]['diem'] = diem
				end
			end
		end
	end
	if (ls2) then 
		ls2.each do |item|
			temp = item[:ma_mon_hoc].strip
			diem =  item[:diem_max].strip
			if (replace[temp]) then temp = replace[temp] end
			if (status[temp]) then 
				if (danghoc[temp] == 1) then 
					status[temp]['tinhtrang'] = mdanghoc
					status[temp]['diem'] = item[:diem_max].strip	
				else
					unless (status[temp]['tinhtrang'] == pass)
						status[temp]['tinhtrang'] = fail	
						status[temp]['diem'] = item[:diem_max].strip	
					end
				end	
			else 
				if (replace[temp] == nil) then 
					status[temp] = {}
					status[temp]['tinhtrang'] = fail			
					status[temp]['diem'] = diem
				end
			end	
		end
	end
	i = 0
	j = 0
	sbjs.each do |k,v|
		if (v > 0) then 		
			courses[k] = i
			i = i + 1		
		else
			courses2[k] = j
			j = j + 1
		end
	end

	courses2_json = []
	courses2.each do |k,v|
		courses2_json.push({"name" => status[k]['ten']})
	end
	
	courses.each do |k,v|	

		if (status[k]) then 				

			if (status[k]['makhoi']=='4') then 
				status[k]['nhom'] = mas + 1
				ro(status, deps, k, mas + 1)				
			end 		
		end	
	end
	if (ls_dk) then 
		ls_dk.each do |item| 
			links.push({"source" => courses[item[:ma_mon_hoc1].strip],
						"target" => courses[item[:ma_mon_hoc2].strip]})		

		end
	end
	enable = '#9900FF'
=begin
	courses.each do |k, v|
		temp = deps[k]
		if (temp) then 
				status[k]['leaf'] = 0		
		else
			status[k]['leaf'] = 1
		end
		if (status[k]['nhom'] == 1 and status[k]['tinhtrang'] == disable) then 
			status[k]['tinhtrang'] = enable
		end
		if (status[k]['tinhtrang'] == pass or status[k]['tinhtrang'] == fail) then 			
			if (temp) then 						
				temp.each do |item|
					if (status[item]['tinhtrang'] == disable) then status[item]['tinhtrang'] = enable end
				end
			end
		end
	end
=end
	courses.each do |k, v|
		truoc = prev[k]
		sau = deps[k]
		if (status[k]) then 
			if (sau) then status[k]['leaf'] = 0 else status[k]['leaf'] = 1 end
			if (status[k]['nhom'] == 1 and status[k]['tinhtrang'] == disable) then 
				status[k]['tinhtrang'] = enable
			end

			if (truoc and status[k]['tinhtrang'] == disable) then 
				duocdk = true
				truoc.each do |montruoc|
					if (status[montruoc]) then 
						if (status[montruoc]['tinhtrang'] == disable or status[montruoc]['tinhtrang'] == enable) then					
							duocdk = false
						end	
					end
				end	
				if (duocdk == true ) then status[k]['tinhtrang'] = enable 
				else status[k]['tinhtrang'] = disable end
			end
		end 
	end
	sbjs.each do |k,v|
		if (v > 0) then 	
			if (status[k]) then 		
			nodes.push({"name" => status[k]['ten'], 
					"group" => status[k]['nhom'], 
					"color" => status[k]['tinhtrang'],
					"mamon" => k,
					"tuchon" => status[k]['tuchon'],
					"tennhom" => (status[k]['tennhom']) ? status[k]['tennhom']: '',
					"somontuchon" => status[k]['somontuchon'],
					"khoikienthuc" => status[k]['khoikienthuc'],
					"leaf" => status[k]['leaf'],
					"dvht" => status[k]['khoiluong'],
					"diem" => (status[k]['diem']) ? status[k]['diem'] : '',
					"thaythe" => (status[k]['thaythe']) ?   status[k]['thaythe'] : '' })
			end
		end
	end

	tags["nodes"] = nodes
	tags["links"] = links
	tags["other"] = courses2_json

	return tags.to_json
end

def ro(status, deps, item, mas)
	if (!deps[item]) then
		return status[item]['nhom']
	  end		 	
		deps[item].each do |it|
			if (status[it]) then 
				status[it]['nhom'] = [status[it]['nhom'],status[item]['nhom'] + 1].max				
				tmp = ro(status, deps, it, status[it]['nhom'])		
				mas = [tmp, mas].max
			end
		end	
	return mas	
end

def ri(status, deps, item)	
	if (!deps[item]) then return 
	else
		temp = status[item]['tinhtrang'].strip
		if (temp == pass or temp == fail) then 
			deps[item].each do |it|
				if (status[it]['tinhtrang'].strip == disable) then
					status[it]['tinhtrang'].strip = enable		
					puts it 											
				else 
					ri(status, deps, it)
				end
			end
		end
	end
end

 
 