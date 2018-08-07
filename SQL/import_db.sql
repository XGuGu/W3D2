PRAGMA foreign_keys = ON;

CREATE TABLE users (
  id INTEGER PRIMARY KEY,
  fname VARCHAR(255) NOT NULL,
  lname VARCHAR(255) NOT NULL
);

CREATE TABLE questions (
  id INTEGER PRIMARY KEY,
  title VARCHAR(255) NOT NULL,
  body TEXT NOT NULL,
  author_id INTEGER NOT NULL,

  FOREIGN KEY(author_id) REFERENCES users(id)
);

CREATE TABLE questions_follows (
  id INTEGER PRIMARY KEY,
  user_id INTEGER NOT NULL,
  question_id INTEGER NOT NULL,

  FOREIGN KEY(user_id) REFERENCES users(id),
  FOREIGN KEY(question_id) REFERENCES questions(id)
);



CREATE TABLE replies (
  id INTEGER PRIMARY KEY,
  question_id INTEGER NOT NULL,
  parent_reply_id INTEGER,
  author_id INTEGER NOT NULL,
  body TEXT NOT NULL,

  FOREIGN KEY(question_id) REFERENCES questions(id),
  FOREIGN KEY(parent_reply_id) REFERENCES replies(id),
  FOREIGN KEY(author_id) REFERENCES users(id)

);

CREATE TABLE question_likes (
  id INTEGER PRIMARY KEY,
  question_id INTEGER NOT NULL,
  user_id INTEGER NOT NULL,

  FOREIGN KEY(question_id) REFERENCES questions(id),
  FOREIGN KEY(user_id) REFERENCES users(id)
);

INSERT INTO
  users(fname, lname)
VALUES
  ('Jake', 'Seo'),
  ('Andy', 'Zhang'),
  ('Andre', 'Chow'),
  ('Benji', 'Rothman'),
  ('Mashu', 'Duek');

INSERT INTO
  questions(title, body, author_id)
VALUES
  ('ruby','what is ruby?',(SELECT 1 from users where fname = 'Jake' and lname = 'Seo')),
  ('sql','why is sql so hard?',(SELECT 2 from users where fname = 'Andy' and lname = 'Zhang')),
  ('ruby','how to write each?',(SELECT 3 from users where fname = 'Andre' and lname = 'Chow')),
  ('sql','how to use select?',(SELECT 4 from users where fname = 'Benji' and lname = 'Rothman')),
  ('sql','how to use join?',(SELECT 4 from users where fname = 'Benji' and lname = 'Rothman'));

INSERT INTO
  questions_follows(user_id, question_id)
VALUES
  ((SELECT id from users where fname = 'Jake' and lname = 'Seo'),
  (SELECT id from questions where title = 'ruby' and body = 'what is ruby?')),

  ((SELECT id from users where fname = 'Andy' and lname = 'Zhang'),
  (SELECT id from questions where title = 'sql' and body = 'why is sql so hard?')),

  ((SELECT id from users where fname = 'Andre' and lname = 'Chow'),
  (SELECT id from questions where title = 'ruby' and body = 'how to write each?')),

  ((SELECT id from users where fname = 'Benji' and lname = 'Rothman'),
  (SELECT id from questions where title = 'sql' and body = 'how to use join?'));

INSERT INTO
  replies(question_id, parent_reply_id, author_id, body)
VALUES
  ((SELECT id from questions where title = 'ruby' and body = 'what is ruby?'),
  NULL,
  (SELECT id from users where fname = 'Mashu' and lname = 'Duek'),
  'program language'),

  ((SELECT id from questions where title = 'sql' and body = 'why is sql so hard?'),
  NULL,
  (SELECT id from users where fname = 'Mashu' and lname = 'Duek'),
  'because it is hard'),

  ((SELECT id from questions where title = 'ruby' and body = 'how to write each?'),
  -- (SELECT id FROM replies where body = 'program language' ),
  1,
  (SELECT id from users where fname = 'Mashu' and lname = 'Duek'),
  'self.each {|el| el...}'),

  ((SELECT id from questions where title = 'sql' and body = 'how to use join?'),
  -- (SELECT id FROM replies where body = 'because it is hard' ),
  2,
  (SELECT id from users where fname = 'Mashu' and lname = 'Duek'),
  'JOIN table2 ON table1.id = table2.id');


INSERT INTO
  question_likes(question_id, user_id)
VALUES
((SELECT id from questions where title = 'ruby' and body = 'what is ruby?'),
(SELECT id from users where fname = 'Jake' and lname = 'Seo')),

((SELECT id from questions where title = 'sql' and body = 'why is sql so hard?'),
(SELECT id from users where fname = 'Andy' and lname = 'Zhang')),

((SELECT id from questions where title = 'ruby' and body = 'how to write each?'),
(SELECT id from users where fname = 'Andre' and lname = 'Chow')),

((SELECT id from questions where title = 'sql' and body = 'how to use join?'),
(SELECT id from users where fname = 'Benji' and lname = 'Rothman')),

(3,1),
(4,1),
(5,1),
(5,2),
(4,2);
