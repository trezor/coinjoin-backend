import requests


class RpcClient:
    def __init__(self, destination, user, password):
        self.destination = destination
        self.user = user
        self.password = password

    def _call(self, method_name, parameters={}):
        payload = {
            "jsonrpc": "1.0",
            "method": method_name,
            "params": parameters,
            "id": None,
        }
        socket_response = requests.post(
            self.destination, json=payload, auth=(self.user, self.password)
        )
        try:
            rpc_response = socket_response.json()
        except:
            socket_response.raise_for_status()

        error = rpc_response.get("error", None)
        if error:
            raise Exception("RPC error {}: {}".format(error["code"], error["message"]))
        return rpc_response["result"]

    def __getattr__(self, name):
        if not name.startswith("_"):

            def method(**kargs):
                return self._call(name, kargs)

            return method
