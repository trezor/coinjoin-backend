from rpc_client import RpcClient


class Bitcoin:
    def __init__(self, destination, user, password):
        self.client = RpcClient(destination, user, password)
        self.address = None

    def generate_blocks(self, count=1):
        if self.address is None:
            self.address = self.client.getnewaddress()
        self.client.generatetoaddress(nblocks=count, address=self.address)

    def generate_block_if_needed(self):
        if self.client.getmempoolinfo()["size"]:
            self.generate_blocks()

    def send(self, address, amount, mempool = False):
        if mempool is True:
            self.client.sendtoaddress(address=address, amount=amount, avoid_reuse=False)
        else:
            self.send_multiple({address: amount})

    def send_multiple(self, invoice):
        total = sum(invoice.values())
        assert 0 < total <= 1000
        while self.client.getbalance() < total:
            self.generate_blocks()
        for address, amount in invoice.items():
            self.client.sendtoaddress(address=address, amount=amount, avoid_reuse=False)
        self.generate_blocks()
