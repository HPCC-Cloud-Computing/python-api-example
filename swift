#!/usr/bin/env python

import requests, sys, getopt, os.path


endpoint_keystone = 'http://127.0.0.1:5000/v2.0/'
endpoind_swift = 'http://127.0.0.1:8080/v1/AUTH_612427e5408e41a0a35604fe8a3e5370'

# KEYSTONE
def get_tokens(auth):
	'api connect'
	print 'User ' + auth['auth']['passwordCredentials']['username']
	print "wait request tokens..."
	r = requests.post('http://127.0.0.1:5000/v2.0/tokens', json = auth)
	if r.status_code == requests.codes.ok:
		# print r.json()
		res = r.json()
		return res['access']['token']['id']
	return False


def get_containers(tokens):
	'api connect'
	headers = {'X-Auth-Token': tokens}
	r = requests.get(endpoint_swift+'?format=json', headers = headers)
	if r.status_code == requests.codes.ok:
		return r.json()
	return False;		

def get_objects(tokens, name_container):
	'api connect'
	headers = {'X-Auth-Token': tokens}
	r = requests.get(endpoint_swift+'/'+name_container+'?format=json', headers = headers)
	if r.status_code == requests.codes.ok:
		return r.json()
	return False;			


def list_containers(auth):
	tokens = get_tokens(auth)
	containers = get_containers(tokens)

	print '\033[32m---------list containers --------------\033[0m'
	for i in range(len(containers)):
		print 'name: ' +containers[i]['name'] + "\t\t"+ 'bytes: '+str(containers[i]['bytes'])
		
def list_objects(auth, name_container):
	tokens = get_tokens(auth)
	objects = get_objects(tokens, name_container)

	if (objects == False):
		print 'containers not exist'
		sys.exit()
	print '\033[32m---------list objects: '+ name_container +' --------------\033[0m'
	for i in range(len(objects)):
		print 'name: ' +objects[i]['name'] + "\t\t"+ 'bytes: '+str(objects[i]['bytes'])

def upload_objects(auth):
	tokens = get_tokens(auth)
	name_container = raw_input('Enter containers: ')

	objects = get_objects(tokens, name_container)

	if (objects == False):
		print 'containers not exist'
		sys.exit()
	name_file = raw_input('Enter file: ')
	if (os.path.isfile(name_file) == False):
		print 'File not found!'
		sys.exit()

	f = open(name_file, 'r')
	data = f.read()

	headers = {'X-Auth-Token': tokens}
	r = requests.put(endpoint_swift+'/'+name_container+'/'+name_file+'?format=json', headers = headers, data = data)
	if r.status_code == 201:
		print "Upload "+name_file +" successed!"
	else :
		print 'Faild!'

	sys.exit()

def help():
	print "Script use: list image, list flavor, creat server "
	print "\t-h, --help\t\tshow this help"
	print "\t-c, --containers\t\tlist containers"
	print "\t-o, --objbect {name_container}\t\tlist objbect"
	print "\t-u, --upload\t\tupload object"
	sys.exit()

if __name__ == "__main__":
	if len(sys.argv) == 1:
		help()
		sys.exit()

	options , remainder = getopt.getopt(sys.argv[1:], 'hluo:', ['help', 'list', 'upload', 'object='])

	#auth user, password
	auth = {"auth":{"tenantName":"demo","passwordCredentials":{"username":"demo","password":"demo"}}}

	for opt, args in options:

		if opt in ('-h', '--help'):
			help()
			sys.exit()

		if opt in ('-l', '--list'):
			list_containers(auth)
			sys.exit()				

		if opt in ('-u', '--upload'):
			upload_objects(auth)
			sys.exit()				

		if opt in ('-o', '--object'):
			list_objects(auth, args)
			sys.exit()					
	

