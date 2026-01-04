class WrongPassword extends Error {
    constructor(message) {
      super(message);
      this.name = 'Bad Request';
    }
}

class DuplicateEntry extends Error {
  constructor(message = 'Duplicate Entry for Same user and site') {
    super(message);
    this.name = 'Bad Request';
  }
}

export { WrongPassword, DuplicateEntry };