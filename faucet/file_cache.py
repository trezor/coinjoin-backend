class FileCache:
    def __init__(self):
        self.cache = {}

    def get_file(self, file_path, force_reload=False):
        if file_path not in self.cache or force_reload:
            with open(file_path, "rb") as file:
                file_content = file.read()
            self.cache[file_path] = file_content

        return self.cache[file_path]

    def wipe_cache(self):
        self.cache = {}
