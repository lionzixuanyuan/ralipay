module Common

  require 'openssl'

  #生成签名结果
  def self.build_sign(data_array, sign_type = 'RSA', rsa_private_key_path = '')
    #把数组所有元素，按照“参数=参数值”的模式用“&”字符拼接成字符串
    for_sign_string = self.create_link_string(data_array)
    #签名
    if sign_type == 'RSA'
      return self.rsa_sign(for_sign_string,rsa_private_key_path)
    elsif sign_type == 'MD5'
      return self.md5_sign(for_sign_string)
    else
      fail('Unknown sign_type!')
    end
  end

  #把数组所有元素，排序后按照“参数=参数值”的模式用“&”字符拼接成字符串
  def self.create_link_string(array)
    result_string = ''
    array = array.sort
    array.each{|key,value|
      result_string += (key + '=' + value + '&')
    }
    #去掉末尾的&
    result_string = result_string[0, result_string.length - 1]
    return result_string
  end

  #RSA签名
  def self.rsa_sign(for_sign_string,rsa_private_key_path)
    #读取私钥文件
    rsa_private_key_file = File.read(rsa_private_key_path)
    #转换为openssl密钥
    openssl_key = OpenSSL::PKey::RSA.new rsa_private_key_file
    #使用openssl方法进行sha1签名digest(不能用sha256)
    digest = OpenSSL::Digest::SHA1.new
    signature = openssl_key.sign digest, for_sign_string
    #base64编码
    signature = Base64.encode64(signature)
    #signature = signature.gsub!("\n",'')
    return signature
  end

  #MD5签名
  def self.md5_sign(for_sign_string)

  end

  #验签
  def verify?(for_sign_string, signed_string, rsa_public_key_path)
    #读取公钥文件
    rsa_public_key_file = File.read(rsa_public_key_path)
    openssl_public = OpenSSL::PKey::RSA.new rsa_public_key_file
    digest = OpenSSL::Digest::SHA1.new
    openssl_public.verify(digest, Base64.decode64(signed_string), for_sign_string)
  end

end