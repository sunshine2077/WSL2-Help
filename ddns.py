import requests
import netifaces
local_const="目前的IPV6地址"
print("===检测本机IPV6地址===")
cfg={
    "zid":"域名的id",
    "IPV6":netifaces.ifaddresses('eth0')[netifaces.AF_INET6][0]['addr'],
    "HOSTNAME":"www"
}
if cfg["IPV6"]==local_const:
    print("IP地址未发生改变")
    exit(1)
api_url="https://api.cloudflare.com/client/v4/zones/{}"\
        "/dns_records?type=AAAA&name={}&content={}&page=1&per_page=100"\
            "&order=type&direction=desc&match=any".format(cfg["zid"],cfg["HOSTNAME"],cfg["IPV6"])
header={
    "X-Auth-Email":"邮箱名@126.com",
    "X-Auth-Key":"clousflare的key",
    "Content-Type":"application/json",
}
print('===发送DNS变更请求====')
try:
    ans=requests.get(api_url,headers=header)
except:
    print("发送GET请求异常")
    exit(-1)
result=ans.json()
if not result["success"]:
    print("请求失败，错误码:{}:".format(result["errors"][0]["code"]),result["errors"][0]["message"])
else:
    print("请求成功")
    exit(1)
