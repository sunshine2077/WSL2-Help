import requests
import netifaces
import sqlite3
conn = sqlite3.connect('test.db')
cmd=conn.cursor()
datas = cmd.execute("SELECT key, value  from MAIN")
for temp in datas:
    local_const=temp[1]
    break
print("===检测本机IPV6地址===")
cfg={
    "zid":"bf3314493769daffdf286898645a90a3",
    "IPV6":netifaces.ifaddresses('eth0')[netifaces.AF_INET6][0]['addr'],
    "HOSTNAME":"www"
}
print(local_const,cfg["IPV6"])
if cfg["IPV6"]==local_const:
    print("IP地址未发生改变")
    exit(1)
print("===检测到IP变更，最新IP：{}===".format(cfg["IPV6"]))
header={
    "X-Auth-Email":"kuainazhou@126.com",
    "X-Auth-Key":"facf6ee86b9e9e9ad7fae944d5664e7a746ad",
    "Content-Type":"application/json",
}
def getDNSID():
    print('===获取DNS ID====')
    api_getdnsid_url="https://api.cloudflare.com/client/v4/zones/{}"\
        "/dns_records?type=AAAA&name={}&content={}&page=1&per_page=100"\
            "&order=type&direction=desc&match=any".format(cfg["zid"],cfg["HOSTNAME"],cfg["IPV6"])
    ans=requests.get(api_getdnsid_url,headers=header).json()
    if not ans["success"]:
            print("请求失败!信息：",ans['errors']['message'])
    domain_id={}
    for result in ans['result']:
        print(result)
        domain_id[result['name']]=result['id']
    return domain_id
def updateDNS(ids):
    print('===发送DNS变更请求====')
    for domain in ids:
        api_updatedns_url="https://api.cloudflare.com/client/v4/zones/{}/dns_records/{}".format(cfg["zid"],ids[domain])
        result=requests.put(api_updatedns_url,headers=header,json={
            'type': 'AAAA', 
            'name': domain, 
            'content': cfg['IPV6'], 
            'ttl': 120,
            'proxied': False,
            }).json()
        if not result["success"]:
            print("请求失败,id={},domain={},原因:{}".format(ids[domain],domain,result['errors']['message']))
            print(result)
        else:
            print("请求成功,id={},domain={}".format(ids[domain],domain))
    print('所有请求完成')
#ids=getDNSID()
ids={
     'test.tianqingjian.eu.org':'bc6e19a999e96001a40bbf1d446685a6',
     'www.tianqingjian.eu.org':'2f85d760e087918c5e7edb499bf80cb5',
}
updateDNS(ids)
cmd.execute("UPDATE MAIN SET VALUE='{}' WHERE key='IPV6'".format(cfg['IPV6']))
conn.commit()
conn.close()
print("执行退出")


